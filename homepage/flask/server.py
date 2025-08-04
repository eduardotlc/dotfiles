from flask import Flask, request, jsonify, render_template
import json

app = Flask(__name__)

# File to store notes
notes_file = "notes.json"


def load_notes():
    try:
        with open(notes_file, "r") as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError):
        return []  # Return an empty list if the file doesn't exist or is empty


def save_note(note):
    notes = load_notes()
    notes.append(note)
    with open(notes_file, "w") as file:
        json.dump(notes, file)


@app.route("/")
def home():
    notes = load_notes()
    return render_template("notes.html", notes=notes)


@app.route("/add_note", methods=["POST"])
def add_note():
    note_data = request.get_json()
    if note_data and "note" in note_data:
        save_note(note_data["note"])
        return jsonify({"success": True})
    return jsonify({"success": False})


if __name__ == "__main__":
    app.run(debug=True, port=8001, host="http://127.0.0.1")
