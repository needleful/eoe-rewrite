
module np.dialog.sequence;

import np.dialog.conditions;

struct DialogItem {
	enum Type {
		message,
		reply,
		narration,
		contextualReply
	}

	Type type = Type.message;
	int next = -1, child = -1, parent = -1;
	string text = "", speaker = "";
	Result function(const ref Context) condition = null;

	bool requiresInput(){
		return type == Type.reply;
	}

	bool isContextual() {
		return type == Type.contextualReply;
	}

	Result check(const ref Context context) {
		if(!condition) {
			return Result.success;
		}
		else {
			return condition(context);
		}
	}

	// Fluent API for testing
	DialogItem* withNeighbors(int p_next, int p_child = -1, int p_parent = -1) {
		next = p_next;
		child = p_child;
		parent = p_parent;
		return &this;
	}

	DialogItem* withMessage(Type t, string p_speaker, string p_message) {
		type = t;
		speaker = p_speaker;
		message = p_message; 
		return &this;
	}

	DialogItem* withCondition(Result function(const ref Context) p_cond) {
		condition = p_cond;
		return &this;
	}

	static DialogItem branch(Result function(const ref Context) p_cond) {
		DialogItem d = DialogItem();
		d.condition = p_cond;
		return d;
	}

	static DialogItem message(string p_message, string p_speaker = "") {
		DialogItem d = DialogItem();
		d.text = p_message;
		d.speaker = p_speaker;
		return d;
	}
	static DialogItem narration(string p_message) {
		DialogItem d = DialogItem();
		d.type = Type.narration;
		d.text = p_message;
		return d;
	}
	static DialogItem reply(string p_message) {
		DialogItem d;
		d.type = Type.reply;
		d.text = p_message;
		return d;
	}
}

struct DialogSequence {
	struct Retrieval {
		DialogItem* item;
		// for various reasons, we have to track this
		bool wentUp;

		enum NONE = Retrieval(null, false);

		this(DialogItem* p_item, bool p_up) {
			item = p_item;
			wentUp = p_up;
		}
	}
	static immutable int NOT_PRESENT = -1;

	DialogItem[int] items;
	int[string] labels;

	DialogItem* findIndex(int i) {
		return i in items;
	}

	DialogItem* findLabel(string l) {
		int* i = l in labels;
		if(i is null) {
			return null;
		}
		else {
			return *i in items;
		}
	}

	int indexOf(DialogItem* item) {
		foreach(int i; items.byKey()) {
			if ((i in items) == item) {
				return i;
			}
		}
		return NOT_PRESENT;
	}

	DialogItem* next(DialogItem* item) {
		return findIndex(item.next);
	}

	DialogItem* child(DialogItem* item) {
		return findIndex(item.child);
	}

	DialogItem* parent(DialogItem* item) {
		return findIndex(item.parent);
	}

	Retrieval nextOnSuccess(DialogItem* item) {
		DialogItem* r = child(item);
		if (r) {
			return Retrieval(r, false);
		}
		else {
			return nextAtOrUp(item);
		}
	}

	Retrieval nextOnFailure(DialogItem* item) {
		Retrieval r = nextAtOrUp(item);
		return r;
	}

	private Retrieval nextAtOrUp(DialogItem* item) {
		if(!item) {
			return Retrieval.NONE;
		}
		if(item.type == DialogItem.Type.reply) {
			DialogItem* nrep = next(item);
			while(nrep) {
				if(nrep.type != DialogItem.Type.reply) {
					return Retrieval(nrep, false);
				}
				nrep = next(nrep);
			}
		}
		else {
			DialogItem* nrep = next(item);
			if(nrep) {
				return Retrieval(nrep, false);
			}
		}
		Retrieval r = nextAtOrUp(parent(item));
		r.wentUp = true;
		return r;
	}
}