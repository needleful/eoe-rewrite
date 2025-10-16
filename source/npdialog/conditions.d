
module np.dialog.conditions;


struct Context {
	int talked;
	bool otherwise;
}

struct Result {
	enum Type {
		success,
		failure,
		end
	}

	Type type;

	static immutable Result success = Result(Type.success);
	static immutable Result failure = Result(Type.failure);
	static immutable Result end = Result(Type.end);

	this(Type p_type) {
		type = p_type;
	}

	bool opBool() {
		return type != Type.failure;
	}

	static Result of(bool b) {
		return b? Result.success : Result.failure;
	}
}