class StackCommand {
	
	isNil(): Bool { true };
	top(): String { { abort(); ""; } };
	tail(): StackCommand { { abort(); self; } };
	cons(s: String): StackCommand {
		(new Cons).init(s, self)
	};

};

class Cons inherits StackCommand {

	elem: String;        -- the top element of the stack
	next: StackCommand;  -- the rest of the stack

	isNil(): Bool { false };
	top(): String { elem };
	tail(): StackCommand { next };
	init(s: String, rest: StackCommand): StackCommand {
		{
			elem <- s;
			next <- rest;
			self;  -- return value
		}
	};

};


class Main inherits IO {

	mystack: StackCommand;

	print_stack(stack: StackCommand): Object {
		if stack.isNil() then out_string("\n")
		else {
			out_string(stack.top());
			out_string("\n");
			print_stack(stack.tail());
		}
		fi
	};

	add(stack: StackCommand): Object {
		let first: Int,
			second: Int,
			result: String
		in {
			mystack <- mystack.tail();  -- pop "+" from front
			first <- (new A2I).a2i(mystack.top());
			mystack <- mystack.tail();
			second <- (new A2I).a2i(mystack.top());
			mystack <- mystack.tail();
			result <- (new A2I).i2a(first + second);
			mystack <- mystack.cons(result);  -- add the result back to stack
		}
	};
	
	swap(stack: StackCommand): Object {
		let first: String,
			second: String
		in {
			mystack <- mystack.tail(); -- pop "s" from front
			first <- mystack.top();
			mystack <- mystack.tail();
			second <- mystack.top();
			mystack <- mystack.tail();
			mystack <- mystack.cons(second).cons(first);  -- swap two elements
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
				out_string("pushed ");
				out_string(cmd);
				out_string(" to stack\n");
				mystack <- (new StackCommand).cons(cmd);
			}
			fi fi;
		} pool
   };

};
