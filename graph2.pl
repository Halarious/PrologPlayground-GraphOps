is_cycle([e(Node,NextNode)|Cycle], graph(_, Edges), Node) :- adj(Node, NextNode, Edges),
						       	     delete(Edges, 	    e(Node, NextNode), EdgesSansEdge0),
						       	     delete(EdgesSansEdge0, e(NextNode, Node), EdgesSansEdge),
					  		     cycle(Cycle, EdgesSansEdge, Node, NextNode).


cycle(_, _, StartNode, StartNode).
cycle([e(CurrentNode, NextNode)|CycleTail], Edges, StartNode, CurrentNode) :- adj(CurrentNode, NextNode, Edges),
								 	      delete(Edges, 	     e(CurrentNode, NextNode), EdgesSansEdge0),
								 	      delete(EdgesSansEdge0, e(NextNode, CurrentNode), EdgesSansEdge),
								 	      cycle(CycleTail, EdgesSansEdge, StartNode, NextNode).

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




s_tree(graph([N|Ns],GraphEdges),graph([N|Ns],TreeEdges)) :-
   transfer(Ns,GraphEdges,TreeEdgesUnsorted),
   sort(TreeEdgesUnsorted,TreeEdges).

% transfer(Ns,GEs,TEs) :- transfer edges from GEs (graph edges)
%    to TEs (tree edges) until the list NS of still unconnected tree nodes
%    becomes empty. An edge is accepted if and only if one end-point is
%    already connected to the tree and the other is not.

transfer([],_,[]).
transfer(Ns,GEs,[GE|TEs]) :-
   select(GE,GEs,GEs1),        % modified 15-May-2001
   incident(GE,X,Y),
   acceptable(X,Y,Ns),
   delete(Ns,X,Ns1),
   delete(Ns1,Y,Ns2),
   transfer(Ns2,GEs1,TEs).

incident(e(X,Y),X,Y).
incident(e(X,Y,_),X,Y).

acceptable(X,Y,Ns) :- memberchk(X,Ns), \+ memberchk(Y,Ns), !.
acceptable(X,Y,Ns) :- memberchk(Y,Ns), \+ memberchk(X,Ns).
