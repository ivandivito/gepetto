package fiuba.gepetto;

import fiuba.gepetto.home.HomeWindow;

import javax.swing.*;
import java.awt.*;

public class Gepetto {

    private HomeWindow window = null;

    public Gepetto(){

    }

    public void startUI(){

        EventQueue.invokeLater(() -> {
            window = new HomeWindow();
            window.setLocationRelativeTo(null);
            window.setVisible(true);

        });

    }

    public static void main(String[] args){

        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());

            new Gepetto().startUI();
        }
        catch (UnsupportedLookAndFeelException | ClassNotFoundException | InstantiationException | IllegalAccessException e) {
            e.printStackTrace();
        }

    }

}
