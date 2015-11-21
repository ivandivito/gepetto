package fiuba.gepetto.home;

import fiuba.gepetto.utils.Constants;
import jssc.*;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.nio.ByteBuffer;
import java.util.Arrays;

public class HomeWindow extends JFrame implements KeyListener {

    private JMenu portMenu;
    private JMenuItem refreshItem;

    private JTextArea textArea;
    private JTextField textField;

    private JFileChooser fileChooser = new JFileChooser();

    private StringBuffer buffer = new StringBuffer();
    private SerialPort serialPort = null;

    private FileReader fileReader = null;
    private boolean transferingFile = false;

    private boolean headerSent = false;
    private boolean lineCountSent = false;
    private long lineCount = 0;
    private int linesTransfered = 0;

    public HomeWindow(){
        initializeUI();
    }

    private void initializeUI(){

        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setTitle(Constants.WINDOW_TITLE);

        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                closePort();
            }
        });

        JMenuBar menuBar = new JMenuBar();
        portMenu = new JMenu(Constants.WINDOW_PORT);
        menuBar.add(portMenu);

        refreshItem = new JMenuItem(Constants.WINDOW_REFRESH_PORTS);
        refreshItem.addActionListener(e -> refreshSerialPortList());

        portMenu.add(refreshItem);

        setJMenuBar(menuBar);

        Container mainPane = getContentPane();

        mainPane.setLayout(new BorderLayout());

        textArea = new JTextArea();
        textArea.setRows(16);
        textArea.setColumns(40);
        textArea.setEditable(false);

        JScrollPane scrollPane = new JScrollPane(textArea);

        mainPane.add(scrollPane, BorderLayout.CENTER);

        JPanel lowerPane = new JPanel();
        lowerPane.setLayout(new BoxLayout(lowerPane, BoxLayout.X_AXIS));
        lowerPane.setBorder(new EmptyBorder(4, 4, 4, 4));

        JButton transferFileButton = new JButton(Constants.WINDOW_TRANSFER_FILE);
        transferFileButton.addActionListener(e -> onTransferFileClicked());
        lowerPane.add(transferFileButton);
        lowerPane.add(Box.createRigidArea(new Dimension(4, 0)));

        textField = new JTextField(40);
        textField.addKeyListener(this);

        JButton sendButton = new JButton(Constants.WINDOW_SEND);

        JButton clearButton = new JButton(Constants.WINDOW_CLEAN);
        clearButton.addActionListener(e -> textArea.setText(""));

        sendButton.addActionListener(e -> onSendButtonClicked());

        lowerPane.add(textField);
        lowerPane.add(Box.createRigidArea(new Dimension(4, 0)));
        lowerPane.add(sendButton);
        lowerPane.add(Box.createRigidArea(new Dimension(4, 0)));
        lowerPane.add(clearButton);

        mainPane.add(lowerPane, BorderLayout.SOUTH);

        pack();

        refreshSerialPortList();

    }

    private void onSendButtonClicked(){
        if(!transferingFile)
            transmitMessage(textField.getText());
    }

    private void onTransferFileClicked(){

        if(transferingFile)
            return;

        int returnVal = fileChooser.showOpenDialog(this);

        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = fileChooser.getSelectedFile();

            showInfoMessage("Se selecciono el archivo " + file.getName());

            try {

                lineCount = getFileLineCount(file);

                fileReader = new FileReader(file);

                linesTransfered = 0;
                headerSent = false;
                lineCountSent = false;
                transferingFile = true;

                transmitMessage("$save");

            } catch (IOException e) {
                e.printStackTrace();
            }


        } else {
            showInfoMessage("Se cancelo la transferencia de archivo");
        }

    }

    private long getFileLineCount(File file) throws IOException {

        long count = 0;

        int c;

        try (FileReader inputStream = new FileReader(file)){

            while ((c = inputStream.read()) != -1) {
                if(c == '\n') count ++;
            }

            return count;

        }
    }

    public void showInfoMessage(String message){
        appendMessage("I: " + message + '\n');
    }

    public void showErrorMessage(String message){
        appendMessage("E: " + message + '\n');
    }

    public void showSentMessage(String message){
        appendMessage("T: " + message);
    }

    public void showRecievedMessage(String message){
        appendMessage("R: " + message);
    }

    private void appendMessage(String message){
        textArea.append(message);
        textArea.setCaretPosition(textArea.getDocument().getLength());
    }

    @Override
    public void keyTyped(KeyEvent e) {}

    @Override
    public void keyPressed(KeyEvent event) {

        if(event.getKeyCode() == KeyEvent.VK_ENTER){
            onSendButtonClicked();
        }
    }

    public void transmitMessage(String message){

        if(serialPort == null){
            showErrorMessage("Por favor seleccione un puerto");
            return;
        }

        if(message.isEmpty()){
            showErrorMessage("No se envian mensajes vacios");
            return;
        }

        String text = message + '\n';

        showSentMessage(text);

        try {
            serialPort.writeBytes(text.getBytes());

        } catch (SerialPortException e) {
            showErrorMessage(e.getMessage());
            e.printStackTrace();
        }

        textField.setText("");

    }

    @Override
    public void keyReleased(KeyEvent e) {}

    public boolean openPort(String portName) throws SerialPortException {

        serialPort = new SerialPort(portName);
        if(!serialPort.openPort()){
            return false;
        }

        if(!serialPort.setParams(SerialPort.BAUDRATE_9600, SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_NONE)){
            return false;
        }

        serialPort.addEventListener(
                this::onSerialPortEvent,
                SerialPort.MASK_RXCHAR);

        return true;
    }

    protected void onSerialPortEvent(SerialPortEvent event){

        if(event.isRXCHAR()){

            int count = event.getEventValue();

            if(count == 0)
                return;

            byte[] characters;
            try {

                characters =  serialPort.readBytes(count);

                for(byte character : characters){
                    //System.out.println(Integer.toHexString(character) + "\t:\t" + (int) character + "\t:\t" + (char) character);
                    onReceiveChar((char) character);
                }

            } catch (SerialPortException e) {
                showErrorMessage("No se pudo leer un byte");
                e.printStackTrace();
            }

        }

    }

    private void onReceiveChar(char character){

        buffer.append(character);

        if(buffer.charAt(buffer.length()-1) == '\n'){
            onReceiveLine(buffer.toString());
            buffer.delete(0, buffer.length());
        }

    }

    private void onReceiveLine(String line){

        if(transferingFile){

            if(line.equals("ack\n")){

                if(!headerSent){

                    headerSent = true;
                    transmitMessage("GEPETTO");

                    showInfoMessage("Encabezado enviado");

                } else if(!lineCountSent) {
                    lineCountSent = true;
                    transmitMessage(String.valueOf(lineCount));
                    showInfoMessage("Cantidad de lineas enviadas");

                } else {

                    try {

                        if(linesTransfered<lineCount){

                            transmitMessage(readLine(fileReader));

                            linesTransfered++;

                        } else {

                            try {fileReader.close();} catch (IOException e1) {e1.printStackTrace();}
                            transferingFile = false;

                            showInfoMessage("Transferencia completa");

                        }

                    } catch (IOException e) {
                        e.printStackTrace();
                        try {fileReader.close();} catch (IOException e1) {e1.printStackTrace();}
                        transferingFile = false;
                        showInfoMessage("Error en la transferencia");
                    }

                }

            } else {

                try {fileReader.close();} catch (IOException e1) {e1.printStackTrace();}
                transferingFile = false;
                showInfoMessage("Error en la transferencia");

            }

        } else {
            showRecievedMessage(buffer.toString());
        }

    }

    private String readLine(FileReader fileReader) throws IOException {

        StringBuffer line = new StringBuffer();

        int c;

        while((c = fileReader.read()) != '\n'){
            line.append((char) c);
        }

        return line.toString();
    }

    public void closePort(){

        if(serialPort != null){

            try {

                serialPort.closePort();

            } catch (SerialPortException e) {
                e.printStackTrace();
            }

        }

    }

    public void refreshSerialPortList(){

        String[] serialPortList = SerialPortList.getPortNames();

        portMenu.removeAll();

        portMenu.add(refreshItem);

        JMenuItem menuItem;
        for(String serialPort : serialPortList){

            menuItem = new JMenuItem(serialPort);
            menuItem.addActionListener(e -> onSerialPortClicked(e.getActionCommand()));
            portMenu.add(menuItem);

        }

    }

    public void onSerialPortClicked(String portName){

        closePort();
        try {

            openPort(portName);

        } catch (SerialPortException e) {
            e.printStackTrace();
            showErrorMessage(e.getMessage());
        }

    }

}
