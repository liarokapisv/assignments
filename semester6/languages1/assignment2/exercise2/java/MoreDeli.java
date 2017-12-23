import java.util.*;
import java.io.*;

public class MoreDeli {

    interface Iteratable<T> {
        public T iterate(T node) ;
    }

    static class IteratableRange<T> implements Iterable<T> {

        public IteratableRange(Iteratable<T> _iterable, T _start, T _end) {
            iterable = _iterable;
            start = _start;
            end = _end;
        }

        public class IteratableIterator implements Iterator<T> {

            public IteratableIterator () {
                next = start;
                reachedEnd = start == end;
            }

            @Override
            public boolean hasNext() {
                return !reachedEnd;
            }

            @Override
            public T next() {
                T tmp = next;
                reachedEnd = next == end;
                if (next != end){
                    next = iterable.iterate(next);
                }
                return tmp;
            }

            @Override
            public void remove() {}

            private T next;
            private boolean reachedEnd;
        }

        @Override
        public IteratableIterator iterator() { return new IteratableIterator(); }

        private final Iteratable<T> iterable;
        private final T start;
        private final T end;

    }

    static class Node {

        public Node(int _y, int _x) {
            x = _x;
            y = _y;
        }

        @Override
        public boolean equals(Object object) {
            if (!(object instanceof Node)) return false;
            return x == ((Node)object).x && y == ((Node)object).y;
        }

        @Override
        public int hashCode() {
            int hash = 3;
            hash = 71 * hash + this.x;
            hash = 71 * hash + this.y;
            return hash;
        }

        int x;
        int y;
    }

    static ArrayList<String> readInput(String name) throws FileNotFoundException {

        Scanner scanner = new Scanner(new File(name));
        ArrayList<String> lines = new ArrayList<String>();
        
        while (scanner.hasNextLine()) {
            lines.add(scanner.nextLine());
        }

        return lines;
        
    }

    static Node find2d(char c, ArrayList<String> space) {
        for (int i = 0; i < space.size(); ++i) {
            for (int j = 0; j < space.get(i).length(); ++j) {
                if (space.get(i).charAt(j) == c) {
                    return new Node(i, j);
                }
            }
        }
        return new Node(space.size(), space.get(0).length());
    }

    static class PrevIteratable implements Iteratable<Node> {
        public PrevIteratable(int _width, ArrayList<Node> _prevs) {
            width = _width;
            prevs = _prevs;
        }

        @Override
        public Node iterate(Node node) {
            return prevs.get(node.y * width + node.x);
        }

        private ArrayList<Node> prevs;
        private int width;
    }

    public static void main(String[] args) throws FileNotFoundException {
    
        ArrayList<String> space = readInput(args[0]);

        Node start = find2d('S', space);

        int height = space.size();
        int width = space.get(0).length();

        ArrayList<Integer> dists = new ArrayList<Integer>(height * width);
        for (int i = 0; i < height * width; ++i) {
            dists.add(Integer.MAX_VALUE);
        }

        ArrayList<Node> prevs = new ArrayList<Node>(height * width);
        for (int i = 0; i < height * width; ++i) {
            prevs.add(new Node(height, width));
        }

        MoreDeliInfo info = new MoreDeliInfo(3, start, height, width,
                                dists, prevs, space);

        info.distance(start, 0);

        WeightLimitedDijstra<Node> dijstra = new WeightLimitedDijstra<Node>(info);
        dijstra.run();

        Node end = find2d('E', space);

        PrevIteratable iter = new PrevIteratable(width, prevs);
        IteratableRange<Node> range = new IteratableRange<Node>(iter, end, start);

        ArrayList<Node> chain = new ArrayList<Node>();

        for (Node node : range) {
            chain.add(node);
        }

        String directions = new String();

        for (int i = 1; i < chain.size(); ++i) {
            Node node1 = chain.get(i);
            Node node2 = chain.get(i-1);

            if (node2.x > node1.x) directions += 'R';
            if (node2.x < node1.x) directions += 'L';
            if (node2.y > node1.y) directions += 'D';
            if (node2.y < node1.y) directions += 'U';

        }

        directions = new StringBuilder(directions).reverse().toString();

        System.out.println(info.distance(end).toString() + ' ' + directions);

    }

    static class MoreDeliInfo implements WeightLimitedDijstra.DijstraInfo<Node> {
    
        public MoreDeliInfo(int _maxWeigth, Node _start, int _height, int _width,
                            ArrayList<Integer> _dists, ArrayList<Node> _prevs, 
                            ArrayList<String> _space) {
            maxWeight = _maxWeigth;
            start = _start;
            height = _height;
            width = _width;
            dists = _dists;
            prevs = _prevs;
            space = _space;
        }

        @Override
        public int maxWeight() {
            return maxWeight;
        }

        @Override
        public Node start() {
            return start;
        }

        @Override
        public Integer distance(Node node) {
            return dists.get(node.y * width + node.x);
        }

        @Override
        public void distance(Node node, Integer dist) {
            dists.set(node.y * width + node.x, dist);
        }

        @Override
        public Integer adjacentInteger(Node node1, Node node2) {
            if (node2.x > node1.x) {
                return 1;
            } else if (node2.y > node1.y) {
                return 1;
            } else if (node2.x < node1.x) {
                return 2;
            } else {
                return 3;
            }
        }

        @Override
        public void previous(Node node1, Node node2) {
            prevs.set(node1.y * width + node1.x, node2);
        }

        @Override
        public ArrayList<Node> getNeighbours(Node node) {
            ArrayList<Node> neighbours = new ArrayList<Node>();
            if (node.x > 0 && space.get(node.y).charAt(node.x-1) != 'X') 
                neighbours.add(new Node(node.y, node.x-1));
            if (node.x < width-1 && space.get(node.y).charAt(node.x+1) != 'X') 
                neighbours.add(new Node(node.y, node.x+1));
            if (node.y > 0 && space.get(node.y-1).charAt(node.x) != 'X') 
                neighbours.add(new Node(node.y-1, node.x));
            if (node.y < height-1 && space.get(node.y+1).charAt(node.x) != 'X') 
                neighbours.add(new Node(node.y+1, node.x));
            return neighbours;
        }

        private final int maxWeight;
        private final Node start;
        private final int height;
        private final int width;
        private final ArrayList<Integer> dists;
        private final ArrayList<Node> prevs;
        private final ArrayList<String> space;
    }

    static class WeightLimitedDijstra<Node> implements Runnable {

        public WeightLimitedDijstra(DijstraInfo<Node> _info) {
            info = _info;
        }
        
        public interface DijstraInfo<Node> {
            public int maxWeight();
            public Node start();
            public void distance(Node node, Integer dist);
            public Integer distance(Node node);
            public Integer adjacentInteger(Node node1, Node node2);
            public void previous(Node node1, Node node2);
            public List<Node> getNeighbours(Node node);
        }

        private class Record {

            public Record(Node _node, Integer _distance) {
                node = _node;
                distance = _distance;
            }

            public Node node;
            public Integer distance;
        }

        @Override
        public void run() {

            ArrayList<ArrayList<Record>> queue = new ArrayList<ArrayList<Record>>(info.maxWeight() + 1);
            for (int i = 0; i <= info.maxWeight(); ++i) {
                queue.add(new ArrayList<Record>());
            }
            
            queue.get(0).add(new Record(info.start(), info.distance(info.start())));

            while (true) {

                boolean notEmpty = false;

                for (ArrayList<Record> list : queue) {
                    if (!list.isEmpty()) notEmpty = true;
                }
                
                if (notEmpty == false) break;

                while (!queue.get(0).isEmpty()) {

                   Record cur = queue.get(0).get(queue.get(0).size()-1); 
                   queue.get(0).remove(queue.get(0).size()-1);

                   Node curNode = cur.node;
                   Integer curDist = cur.distance;

                   List<Node> neighbours = info.getNeighbours(curNode);

                   for (Node neighbour : neighbours) {
                       Integer weight = info.adjacentInteger(curNode, neighbour);
                       Integer altDist = curDist + weight;

                       if (altDist < info.distance(neighbour)) {
                           info.distance(neighbour, altDist);
                           info.previous(neighbour, curNode);
                           queue.get(weight).add(new Record(neighbour, altDist));
                        }
                    }
                }

                for (int i = 0; i < queue.size()-1; ++i)
                {
                    queue.set(i,queue.get(i+1));
                }

                queue.set(queue.size()-1, new ArrayList<Record>());
            }
                
        }

        private final DijstraInfo<Node> info;
    
    }

}
