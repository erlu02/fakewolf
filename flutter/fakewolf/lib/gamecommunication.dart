import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'websockets.dart';

///
/// Again, application-level global variable
///
GameCommunication game = new GameCommunication();

class GameCommunication {
	static final GameCommunication _game = new GameCommunication._internal();

	///
	/// At first initialization, the player has not yet provided any name
	///
	String _playerName = "";

	///
	/// Before the "join" action, the player has no unique ID
	///
	String _roomID = "";

	List<String> players = <String>[];

	factory GameCommunication(){
		return _game;
	}

	GameCommunication._internal(){
		///
		/// Let's initialize the WebSockets communication
		///
		sockets.initCommunication();

		///
		/// and ask to be notified as soon as a message comes in
		///
		sockets.addListener(_onMessageReceived);
	}

	///
	/// Getter to return the player's name
	///
	String get playerName => _playerName;
	set playerName (s) => _playerName = s;

	/// ----------------------------------------------------------
	/// Common handler for all received messages, from the server
	/// ----------------------------------------------------------
	_onMessageReceived(serverMessage) {
		///
		/// As messages are sent as a String
		/// let's deserialize it to get the corresponding
		/// JSON object
		///
		print("Received raw message:   " + serverMessage);
		Map message = json.decode(serverMessage);
		
		switch (message["action"]) {
		///
		/// When the communication is established, the server
		/// returns the unique identifier of the player.
		/// Let's record it
		///
			case 'room':
				_roomID = message["data"];
				break;

			case 'updateRoom':
				List data = json.decode(message["data"]);
				data.forEach((val) => players.add(val));
				break;

		///
		/// For any other incoming message, we need to
		/// dispatch it to all the listeners
		///
			default:
				_listeners.forEach((Function callback) {
					callback(message);
				});
				break;
		}
	}

	/// ----------------------------------------------------------
	/// Common method to send requests to the server
	/// ----------------------------------------------------------
	send(String action, dynamic data) {
		///
		/// Send the action to the server
		/// To send the message, we need to serialize the JSON
		///
		sockets.send(json.encode({
			"action": action,
			"data": data
		}));
	}

	/// ==========================================================
	///
	/// Listeners to allow the different pages to be notified
	/// when messages come in
	///
	ObserverList<Function> _listeners = new ObserverList<Function>();

	/// ---------------------------------------------------------
	/// Adds a callback to be invoked in case of incoming
	/// notification
	/// ---------------------------------------------------------
	addListener(Function callback) {
		_listeners.add(callback);
	}

	removeListener(Function callback) {
		_listeners.remove(callback);
	}
}