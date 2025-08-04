function saveNote() {
     var noteText = document.getElementById("noteInput").value;
     fetch('/add_note', {
         method: 'POST',
         headers: {
             'Content-Type': 'application/json',
         },
         body: JSON.stringify({ note: noteText })
     }).then(response => response.json())
       .then(data => {
           if (data.success) {
               var notesList = document.getElementById("notesList");
               notesList.innerHTML += `<li>${noteText}</li>`;
               document.getElementById("noteInput").value = ""; // clear the input box
           } else {
               alert("Error saving note.");
           }
       });
}
