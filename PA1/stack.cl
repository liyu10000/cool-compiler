class Stack {

	elem: String <- "";  -- the top element of the stack
	next: Stack;  -- the rest of the stack

	isNil(): Bool { if (elem = "") then true else false fi };
	top(): String { elem };
	pop(): Stack { next };  -- move stack to the next, "pop" the top


	init(s: String, rest: Stack): Stack {
		{
			elem <- s;
			next <- rest;
			self;  -- return value
		}
	};


	push(s: String): Stack {
		(new Stack).init(s, self)
	};

};


class Main inherits IO {
	
	mystack: Stack <- (new Stack);

	print_stack(stack: Stack): Object {
		if (not stack.isNil()) then {
			out_string(stack.top());
			out_string("\n");
			print_stack(stack.pop());
		} else {
			out_string("");
		}
		fi
	};

	add(stack: Stack): Object {
		let first: Int,
			second: Int,
			result: String
		in {
			mystack <- mystack.pop();  -- pop "+" from front
			first <- (new A2I).a2i(mystack.top());
			mystack <- mystack.pop();
			second <- (new A2I).a2i(mystack.top());
			mystack <- mystack.pop();
			result <- (new A2I).i2a(first + second);
			mystack <- mystack.push(result);  -- add the result back to stack
		}
	};
	
	swap(stack: Stack): Object {
		let first: String,
			second: String
		in {
			mystack <- mystack.pop(); -- pop "s" from front
			first <- mystack.top();
			mystack <- mystack.pop();
			second <- mystack.top();
			mystack <- mystack.pop();
			mystack <- mystack.push(first).push(second);  -- swap two elements
		}
	};

   main() : Object {
		let cmd: String <- "" in
		while (not cmd = "x") loop {
			out_string(">");
			cmd <- in_string();
			if (cmd = "d") then
				print_stack(mystack)
			else if (cmd = "e") then {
				let top: String <- mystack.top() in {
					if (top = "+") then 
						add(mystack)
					else if (top = "s") then
						swap(mystack)
					else
						mystack  -- do nothing
					fi fi;
				};
			}
			else {
				--out_string("pushed ");
				--out_string(cmd);
				--out_string(" to stack\n");
				mystack <- mystack.push(cmd);
			}
			fi fi;
		} pool
   };

};
