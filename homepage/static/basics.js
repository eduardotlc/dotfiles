function updateClock() {
  var now = new Date()
  var hours = now.getHours()
  var minutes = now.getMinutes()
  var seconds = now.getSeconds()
  minutes = minutes < 10 ? '0' + minutes : minutes
  seconds = seconds < 10 ? '0' + seconds : seconds
  document.getElementById('clock').innerHTML = hours + ':' + minutes + ':' + seconds
  setTimeout(updateClock, 1000)
}

/**
 * Generate a list of strings, representings all images files possible in a folder, starting
 * in a given name 'number.png', and then adding one by one in the name, goes untill the other
 * given one.
 * @param {number} start - number, in which the list should start at
 * @param {number} end - number, in which the list should end at.
 * @returns {list} a list containing strings of file names, on the order from the first to the end
 */
function generateImageList(start, end) {
  let imageList = []
  for (let i = start; i <= end; i++) {
    imageList.push(`${i}.png`)
  }
  return imageList
}


/**
 * Creates a list containing all images files from a folder, and then chose randomly between one
 * of them.
 */
function chooseBackground() {
  let all_backgrounds = generateImageList(1, 339)
  var index = Math.floor(Math.random() * all_backgrounds.length)
  var selectedBackground = all_backgrounds[index]
  document.querySelector('.background').style.backgroundImage = 'url(/static/backgrounds/' + selectedBackground + ')'
}

function fetchRSS() {
  var feeds = [
    'https://onlinelibrary.wiley.com/feed/15213773/most-recent',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Dancac3',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Daanmf6',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Damrcda',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Daccacs',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Dapchd5',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Dcgdefu',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Dinocaj',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Djaaucr',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Djamsef',
    'https%3A%2F%2Fpubs.acs.org%2Faction%2FshowFeed%3Ftype%3Daxatoc%26feed%3Drss%26jc%3Dnalefd',
    'https%3A%2F%2Fwww.nature.com%2Fnmat.rss',
    'http%3A%2F%2Fwww.nature.com%2Fnmeth%2Fcurrent_issue%2Frss%2F',
    'https%3A%2F%2Fwww.nature.com%2Fnmeth.rss',
    'http%3A%2F%2Frss.sciencedirect.com%2Fpublication%2Fscience%2F13697021',
    'http%3A%2F%2Fonlinelibrary.wiley.com%2Frss%2Fjournal%2F10.1002%2F(ISSN)2196-7350',
    'http%3A%2F%2Fonlinelibrary.wiley.com%2Frss%2Fjournal%2F10.1002%2F(ISSN)1096-9888c',
    'http%3A%2F%2Fonlinelibrary.wiley.com%2Frss%2Fjournal%2F10.1002%2F(ISSN)1863-8899',
    'http%3A%2F%2Fonlinelibrary.wiley.com%2Frss%2Fjournal%2F10.1111%2F(ISSN)1751-1097',
    'http%3A%2F%2Fonlinelibrary.wiley.com%2Frss%2Fjournal%2F10.1002%2F(ISSN)1097-0231',
  ]
  var rsindex = Math.floor(Math.random() * feeds.length)
  var selectedFeed = feeds[rsindex]
  const url = 'https://api.rss2json.com/v1/api.json?rss_url=' + selectedFeed
  if (selectedFeed == 'https%3A%2F%2Fpubs.acs.org%2Faction\*' || selectedFeed == 'http%3A%2F%2Fwww.nature.com\*') {
    fetch(url)
      .then(response => response.json())
      .then(data => {
        const feed = data.items.slice(0, 2)
        const container = document.getElementById('rssFeed')
        container.innerHTML = feed.map(item =>
          `<h2>${data.feed['title']}</h2>
              <br>
              <div class="feed-item">
                <h3>${item.title}</h3>
                <h5>${item.pubDate}</h5>
                <br>
                <p>${item.content}</p>
                <h4>${item.author}<h4>
                <a href="${item.link}" target="_blank">Read more</a>
                <br>
              </div>`).join('')
      })
  } else {
    fetch(url)
      .then(response => response.json())
      .then(data => {
        const feed = data.items.slice(0, 2)
        const container = document.getElementById('rssFeed')
        container.innerHTML = feed.map(item =>
          `<h2>${data.feed['title']}</h2>
              <br>
              <div class="feed-item">
                <h3>${item.title}</h3>
                <br>
                <p>${item.content}</p>
                <h4>${item.author}<h4>
                <a href="${item.link}" target="_blank">Read more</a>
                <br>
              </div>`).join('')
      })
  }
}
function tuyaoff() {
  fetch('http://localhost:8666/set/eb1ccfb0e1ceb0292dv6sr/20/false')
}
function tuyaon() {
  fetch('http://localhost:8666/set/eb1ccfb0e1ceb0292dv6sr/20/true')
}
function tuyabright(brightness) {
  const brighturl = 'http://localhost:8666/set/eb1ccfb0e1ceb0292dv6sr/22/' + brightness
  fetch(brighturl)
}

function toggleFeedContent() {
  var feedcontent = document.getElementById('rssFeed')
  var buttonIcon = document.getElementById('feedButton')
  if (feedcontent.style.display === 'none' || feedcontent.style.display === '') {
    feedcontent.style.display = 'block'
    buttonIcon.style.opacity = '0.3'
  } else {
    feedcontent.style.display = 'none'
    buttonIcon.style.display = 'block'
    buttonIcon.style.opacity = '1'
  }
}

isOriginalIcon = true
function toggleIcon() {
  const button = document.getElementById('svgButton')
  const img = button.querySelector('img')

  if (isOriginalIcon) {
    img.src = 'img/lightbulb-off.svg' // Path to the alternative icon
    isOriginalIcon = false
    fetchData("http://localhost:8666/set/eb1ccfb0e1ceb0292dv6sr/20/false")
  } else {
    img.src = 'img/lightbulb.svg' // Path to the original icon
    isOriginalIcon = true
    fetchData("http://localhost:8666/set/eb1ccfb0e1ceb0292dv6sr/20/true")
  }
}

function fetchData(url) {
  fetch(url) // Change to your actual API URL
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => console.error('Error fetching data:', error))
}

window.onload = function() {
  chooseBackground()
  updateClock()
  fetchRSS()
  toggleFeedContent()
}
fetchRSS()
