module gboardforensics.gatherers.expressionhistory;

import gboardforensics.gatherers;
import gboardforensics.models.expressionhistory;

import std.algorithm;
import std.file;
import std.array;

import d2sqlite3;

/**
 * This represents a gatherer for the expression history
 */
class ExpressionHistoryGatherer : IGatherer
{
	/**
	 * Constructs a gatherer with a given path
	 *
	 * Params:
	 *   path = path to the clipboard file
	 */
	this(string path)
		in(exists(path))
		in(isFile(path))
	{
		_expressionHistory.path = path;
	}

	///
	void gather()
	{
		auto db = Database(_expressionHistory.path);
		scope(exit) db.close();

		_expressionHistory.emojis = db.execute(`SELECT
				emoji,
				base_variant_emoji AS baseEmoji,
				datetime(last_event_millis/1000, 'unixepoch') AS lastTime,
				last_event_millis as lastTimestamp,
				shares
			FROM emoji_shares`)
			.map!(r => r.as!(ExpressionHistory.Emoji))
			.array;

		_expressionHistory.emoticons = db.execute(`SELECT
				emoticon,
				datetime(last_event_millis/1000, 'unixepoch') AS lastTime,
				last_event_millis as lastTimestamp,
				shares
			FROM emoticon_shares`)
			.map!(r => r.as!(ExpressionHistory.Emoticon))
			.array;
	}

	/**
	 * Gets the collected expression history
	 *
	 * Returns: expression history data structure
	 */
	@property const(ExpressionHistory) expressionHistory() const
	{
		return _expressionHistory;
	}

	private ExpressionHistory _expressionHistory;
}