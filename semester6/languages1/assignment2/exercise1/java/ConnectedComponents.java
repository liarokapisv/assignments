import java.util.*;

class ConnectedComponents {
    
    public ConnectedComponents(ComponentsInfo _info) {
        info = _info;
    }

    static class IntPair {

        public IntPair(int _first, int _second) {
            first = _first;
            second = _second;
        }

        int first;
        int second;

    }

    static class ComponentsInfo {

        public ComponentsInfo(int _N, ArrayList<IntPair> _edges) {
            N = _N;
            edges = _edges;
        }

        int N;

        ArrayList<IntPair> edges;

    }   

    static class Component {

        public Component(int _id) {
            id = _id;
            rank = 0;
            parent = this;
        }

        int id;

        int rank;

        Component parent;

        public Component find() {
            if (parent != this) {
                parent = parent.find();
            }

            return parent;
        }

        public void union(Component rhs) {
            Component xRoot = find();
            Component yRoot = rhs.find();

            if (xRoot == yRoot) return;

            if (xRoot.rank < yRoot.rank) 
            {
                xRoot.parent = yRoot;
            }
            else if (xRoot.rank > yRoot.rank) 
            {
                yRoot.parent = xRoot;
            }
            else
            {
                yRoot.parent = xRoot;
                xRoot.rank = xRoot.rank + 1;
            }
        }
    }

    int countComponents () {
        int count = 0;

        if (info.N == 0) return count;

        count = 1;

        ArrayList<Component> components = new ArrayList<Component>();

        for (int id = 1; id <= info.N; ++id) {
            components.add(new Component(id));
        }

        for (int i = 0; i < info.edges.size(); ++i) {
            Component c1 = components.get(info.edges.get(i).first-1);
            Component c2 = components.get(info.edges.get(i).second-1);
            c1.union(c2);           
        }

        Component network = components.get(0);

        for (int id = 1; id <= info.N; ++id) {
            Component xRoot = network.find();
            Component yRoot = components.get(id-1).find();
            if (xRoot != yRoot) {
                count = count + 1;
                xRoot.union(yRoot);
            }
        }

        return count;
    }

    ComponentsInfo info;

}
