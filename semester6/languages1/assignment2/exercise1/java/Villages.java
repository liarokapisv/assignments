import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

public class Villages {

static public void main (String[] args) throws FileNotFoundException {

    int N = 0;
    int M = 0;
    int K = 0;
    
    Scanner scanner = new Scanner (new File (args[0]));

    if (scanner.hasNextInt()){
        N = scanner.nextInt();
    }
    
    if (scanner.hasNextInt()){
        M = scanner.nextInt();
    }
    
    if (scanner.hasNextInt()){
        K = scanner.nextInt();
    }

    boolean flag = true;

    ArrayList<ConnectedComponents.IntPair> roads = new ArrayList<ConnectedComponents.IntPair>();

    while (flag) {
        int f = 0;
        int s = 0;

        if (scanner.hasNextInt()) {
            f = scanner.nextInt();
        }
        else {
            flag = false;
        }

        if (flag && scanner.hasNextInt()) {
            s = scanner.nextInt();
        }
        else {
            flag = false;
        }

        if (flag) {
            ConnectedComponents.IntPair pair = new ConnectedComponents.IntPair(f,s);
            roads.add(pair);
        }
    }

    ConnectedComponents.ComponentsInfo info = new ConnectedComponents.ComponentsInfo(N, roads);

    ConnectedComponents counter = new ConnectedComponents(info);

    int networks = counter.countComponents();

    if (networks > K)
    {
        System.out.println(Integer.toString(networks-K));
    }
    else {
        System.out.println("1");
    }
}

}
