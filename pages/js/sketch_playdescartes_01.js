var img;
var osc = [];
var playing = [];
var points = [];
var pointsActive = [];
var count = false;
var freq = [];
var colour = [];
var display;
var env = [];
var fact = 2;
var kons = 95040*fact;
var relation, a = 2.12, b = 2.04;

function preload() {
  img = loadImage('images/1656_descartes_HexachordCircle_brockt_1978_40.jpg');
};

function setVar() {
    if (img.width/img.height > windowWidth/windowHeight)
    {relation = windowWidth/img.width}
    else {relation = windowHeight/img.height};

  console.log("Grösse des images", img.width, img.height, relation);
}

function setupPoints() {

  x = a * relation; 
  y = b * relation;
  //relation =1;

  points[0] = [343*x, 115*y, 470*x, 240*y, 420*x, 440*y, 335*x, 490*y, 152*x, 440*y, 105*x, 252*y];
  points[1] = [185*x, 405*y, 148*x, 264*y, 252*x, 160*y, 330*x, 160*y, 430*x, 268*y, 388*x, 408*y];
  points[2] = [382*x, 277*y, 358*x, 375*y, 265*x, 398*y, 218*x, 373*y, 195*x, 266*y, 263*x, 204*y];
  
  //points[0].map(function(x) {return x * relation});

  console.log("Points", points);

  freq[0] = [kons/540, kons/486, kons/432, kons/405, kons/360, kons/324];
  freq[1] = [kons/360, kons/324, kons/288, kons/540, kons/480, kons/432];
  freq[2] = [kons/480, kons/432, kons/384, kons/360, kons/320, kons/288];
  
  colour[0] = [200, 100, 100, 100];
  colour[1] = [100, 200, 100, 100];
  colour[2] = [100, 100, 200, 100];
  colour[3] = [200, 100, 100, 200];
  colour[4] = [100, 200, 100, 200];
  colour[5] = [100, 100, 200, 200];

}

function setup() {

  setVar();
  Synthesizer.init();

  var output = createCanvas( windowWidth, windowHeight );
  output.parent(diagram);
  background(255);
  image(img, 0, 0, img.width*relation, img.height*relation);
  setupPoints();

  for (var i=0; i<3; i++) {
    pointsActive = [];
    osc[i] = [];
    playing[i] = [];
    setOsc(i);
    setPoints(i);
  };
  setButton();
  console.log('finished setup.')

}

function setPoints(zahl) {
    noStroke(); 
    fill(colour[zahl]);
    
    for (var i=0; i < points[zahl].length; i=i+2) {
      ellipse(points[zahl][i],points[zahl][i+1],30*a*relation,30*a*relation);
    }
}

function setButton () {
  fill(150);
  textSize(16);
  text("Click points to play", 20*a*relation, 50*b*relation);

  //text("F = " + kons/540 + " Hz", 100*a*relation, 100*b*relation);
  // button = createButton('stop sound');
  // button.position(30*a*relation, 60*b*relation);
  // button.mousePressed(stopSound);
  

  fill(240);
}

function stopSound () {

  console.log("Stop");

  for (var zahl = 0; zahl<3; zahl++) {
    for (var i=0; i < freq[zahl].length; i++) {
      playing[zahl][i]=false;
      osc[zahl][i].stop();
    }
  }
  
}

function setOsc(zahl) {
  
  for (var i=0; i < freq[zahl].length; i++) {
    playing[zahl][i]=false;
    osc[zahl][i] = new Sound();
  };
  console.log('oscillators', zahl, 'finished.');
}


// When the user clicks the mouse
function mousePressed() {
  
  for (var zahl = 0; zahl<3; zahl++) {
    for (var i=0; i < freq[zahl].length; i++) {
      // Check if mouse is inside the circle
      var d = dist(mouseX, mouseY, points[zahl][i*2], points[zahl][(i*2)+1]);
      if (d < 15) {
      // look if the sound already plays or not
        if (!playing[zahl][i]) {
          
          osc[zahl][i].play(freq[zahl][i], 2);
          pointDark(zahl, i*2);
          display = text(freq[zahl][i]+" Hz", 100*a*relation, 50*b*relation);
          playing[zahl][i] = true;
          console.log('playing point', zahl, i);
          
        } else {
         // ramp amplitude to 0 over 0.2 seconds
          // osc[zahl][i].stop();
          // pointLight(zahl, i+2);
          // // fill(240);
          // // rect(490*a*relation+zahl*30, 20*b*relation+(i-1)*20, 20*a*relation, 20*a*relation);
          // playing[zahl][i] = false;
        }
      }
    }
  }
}

function pointDark(ring, index) {


  
  image(img, 0, 0, img.width*relation, img.height*relation);

    for (var zahl = 0; zahl<3; zahl++) {
    noStroke(); 
    fill(colour[zahl]);
    
    for (var i=0; i < points[zahl].length; i=i+2) {
      ellipse(points[zahl][i],points[zahl][i+1],30*a*relation,30*a*relation);
      console.log("setPoint", i, zahl);
    }

  }

  stroke(40); 
  strokeWeight(4);

  fill(colour[ring+3]);
  ellipse(points[ring][index],points[ring][index+1],50*a*relation,50*a*relation);
  count = 100;

}

function pointLight(ring, index) {
  
  image(img, 0, 0, img.width*relation, img.height*relation);

    for (var zahl = 0; zahl<3; zahl++) {
    noStroke(); 
    fill(colour[zahl]);
    
    for (var i=0; i < points[zahl].length; i=i+2) {
      ellipse(points[zahl][i],points[zahl][i+1],30*a*relation,30*a*relation);
      console.log("setPoint", i, zahl);
    }
  }
}


function draw() {

  if (count) {

    count = count-1;

      if (count === 0) {
        count = false;
        image(img, 0, 0, img.width*relation, img.height*relation);

         for (var zahl = 0; zahl<3; zahl++) {
            noStroke(); 
            fill(colour[zahl]);
            
            for (var i=0; i < points[zahl].length; i=i+2) {
              ellipse(points[zahl][i],points[zahl][i+1],30*a*relation,30*a*relation);
              // if (playing[zahl][i]) {
              //   osc[zahl][i].stop(); 
              //   playing[zahl][i] = false
              // };
              stopSound();
              console.log("setPoint", i, zahl);
            } 
         }
         

      }
  };
}



  
  //background(220, 220, 220);



