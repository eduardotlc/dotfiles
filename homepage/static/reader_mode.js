function loadReaderMode() {
    let url = document.getElementById("readerUrl").value;
    if (!url) {
        alert("Please enter a URL.");
        return;
    }

    fetch(`/reader?url=${encodeURIComponent(url)}`)
        .then(response => response.text())
        .then(data => {
            document.getElementById("readerContent").innerHTML = data;
        })
        .catch(error => {
            document.getElementById("readerContent").innerHTML = `<p style="color:red;">Error loading Reader Mode.</p>`;
        });
}
//localStorage.setItem("reader_input_area", loadReaderMode)
