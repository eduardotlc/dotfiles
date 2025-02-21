var slider = document.getElementById("myRange")
var output = document.getElementById("demo")
output.innerHTML = slider.value = localStorage.getItem('brigthness')
slider.oninput = function() {
  output.innerHTML = this.value
  localStorage.setItem('brigthness', this.value)
  fetchJsonData(this.value)
}

function fetchJsonData(sliderValue) {
  const url = `http://localhost:8666/set/eb1ccfb0e1ceb0292dv6sr/22/${sliderValue}`
  fetch(url)
    .then(response => response.json())
    .then(data => {
      console.log('Data fetched:', data)
    })
    .catch(error => {
      console.error('Error fetching data:', error)
    })
}


function initFunctions() {
  chooseBackground()
  updateClock()
  fetchRSS()
  toggleFeedContent()
}
document.getElementById('rssFeed').style.display = 'none'
document.getElementById('feedButton').style.display = 'block'
