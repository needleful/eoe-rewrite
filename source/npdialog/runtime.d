
module np.dialog.runtime;

import np.dialog.conditions;
import np.dialog.sequence;

struct DialogEvaluator {
	Context context;
	DialogSequence* sequence;
	DialogItem* currentItem;

	void start(DialogSequence* p_seq) {
		sequence = p_seq;
		currentItem = p_seq.findIndex(1);
	}

	bool done() {
		return currentItem is null;
	}

	DialogItem* getNext(DialogItem* toFind) {
		DialogItem* item = sequence.nextOnSuccess(toFind).item;
		context.otherwise = false;

		while(item) {
			if(item.requiresInput()) {
				return item;
			}

			Result r = item.check(context);
			if(r == Result.end) {
				return null;
			}
			else if(r == Result.success) {
				if(item.text.length) {
					return item;
				}
				else {
					context.otherwise = false;
					item = sequence.nextOnSuccess(item).item;
					continue;
				}
			}
			else {
				DialogSequence.Retrieval rt = sequence.nextOnFailure(item);
				context.otherwise = !rt.wentUp;
				item = rt.item;
			}
		}
		return null;
	}

	void advance() {
		currentItem = getNext(currentItem);
	}
}