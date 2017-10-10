%Prolog
humanTerm_graphTerm(HumanTerm, GraphTerm) :- nonvar(HumanTerm), !, graphTerm_of_humanTerm(GraphTerm,HumanTerm).
humanTerm_graphTerm(HumanTerm, GraphTerm) :- nonvar(GraphTerm), !, humanTerm_of_graphTerm(HumanTerm, GraphTerm).

graphTerm_of_humanTerm(graph(Nodes, Edges), HumanTerm) :- human_to_graph(HumanTerm, NodesDuplicatedUnsorted, EdgesUnsorted),
							  sort(NodesDuplicatedUnsorted, Nodes),
							  sort(EdgesUnsorted, Edges).

human_to_graph([],[],[]).
human_to_graph([X-Y|ConnectionsTail], [X,Y|NodesTail], [e(X,Y)|EdgesTail]) :- !, human_to_graph(ConnectionsTail, NodesTail, EdgesTail).
human_to_graph([X|ConnectionsTail],   [X  |NodesTail], EdgesTail)  	   :-    human_to_graph(ConnectionsTail, NodesTail, EdgesTail).

humanTerm_of_graphTerm(HumanTerm, graph(Nodes, Edges)) :- graph_to_human(Nodes, Edges, HumanTerm).

graph_to_human(Nodes, [], Nodes).
graph_to_human(Nodes, [e(X,Y)|EdgesTail], [X-Y|ConnectionsTail]) :- delete(Nodes, 	   X, NodesSansNodeX),
								    delete(NodesSansNodeX, Y, NodesSansEdgeNodes),
								    graph_to_human(NodesSansEdgeNodes, EdgesTail, ConnectionsTail).



is_path(Path, graph(_, Edges), StartNode, EndNode) :- path(Path, Edges, StartNode, EndNode).

path([], _, EndNode, EndNode).
path([e(Start, Neighbour)|PathTail], Edges, StartNode, EndNode) :-  start_of_path(Start, Neighbour, StartNode, NeighbourNode),
								    is_edge_in_set(e(Start, Neighbour), Edges),
								    delete(Edges, e(StartNode, _), Edges1),
						      	       	    delete(Edges1, e(_, StartNode), EdgesSansStartNode),
						   	       	    path(PathTail, EdgesSansStartNode, NeighbourNode, EndNode).

start_of_path(StartNode, NeighbourNode, StartNode, NeighbourNode).
start_of_path(NeighbourNode, StartNode, StartNode, NeighbourNode).

is_edge_in_set(e(X, Y), [e(X, Y)|_]).
is_edge_in_set(e(X, Y), [e(Y, X)|_]).
is_edge_in_set(Edge, [_|ListTail]) :- is_edge_in_set(Edge, ListTail).

is_cycle_test(Cycle, graph(_, Edges), Node) :- cycle_test(Cycle, Edges, Node).

cycle_test([e(Node,NextNode)|Path], Edges, StartNode) :-  start_of_path(Node, NextNode, StartNode, NeighbourNode),
							  is_edge_in_set(e(Node, NextNode), Edges),
							  delete(Edges, e(StartNode, NeighbourNode), EdgesSansStartEdge),
							  is_path(Path, graph(_, EdgesSansStartEdge), NeighbourNode, StartNode).

adj(Node, NextNode, [e(Node, NextNode)|_]).
adj(Node, NextNode, [e(NextNode, Node)|_]).
adj(Node, NextNode, [_|EdgesTail]) :- adj(Node, NextNode, EdgesTail).

    
degree(Degree, graph(_, Edges), Node) :- connections_of_node(Connections, Node, Edges), 
					 length(Connections, Degree).

connections_of_node([e(Node, NeighbourNode)|ConnectionsTail], Node, Edges) :- adj(Node, NeighbourNode, Edges), !,
								 	      delete(Edges, 	     e(Node, NeighbourNode), EdgesSansEdge0),
								 	      delete(EdgesSansEdge0,   e(NeighbourNode, Node), EdgesSansEdge),
				      			     		      connections_of_node(ConnectionsTail, Node, EdgesSansEdge).
connections_of_node([], _, _).


is_spanning_tree(STree, graph([_|Nodes], Edges)) :- spanning_tree(STree, Nodes, Edges).

spanning_tree([], [], _).
spanning_tree([TreeHead|TreeTail], Nodes, Edges) :- select(TreeHead, Edges, EdgesSansEdge),
						    incident(TreeHead, Node, NeighbourNode),
						    temp(TreeHead, Nodes),
						    delete(Nodes, Node, NodesSansNode1),
						    delete(NodesSansNode1, NeighbourNode, NodesSansNode),
						    spanning_tree(TreeTail, NodesSansNode, EdgesSansEdge).

incident(e(Node, NeighbourNode), Node, NeighbourNode)
.
is_node_in_set(Node, [Node|_]).
is_node_in_set(Node, [_|NodeTail]) :- is_node_in_set(Node, NodeTail).

temp(e(Node, NeighbourNode), Nodes) :- is_node_in_set(NeighbourNode, Nodes),
				       \+ is_node_in_set(Node, Nodes), !.
temp(e(Node, NeighbourNode), Nodes):-  is_node_in_set(Node, Nodes),
				       \+ is_node_in_set(NeighbourNode, Nodes).

