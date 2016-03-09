void keyPressed()
{  
  if (key == CODED) {
    if (keyCode ==UP) {
      zoomIn();
    } else if (keyCode == DOWN) {
      zoomOut();
    } else if (keyCode == RIGHT) {
      angle += .03;
    } else if (keyCode == LEFT) {
      angle -= .03;
    }
  }
  if (key == ' ') {
    initialiseZoom();
  }

  if ( key == 'c' )  //clears screen and resets the script
  {
    initialize();
    loop();
    i0 = 0;
    running = true;
    return;
  }
    if ( key == 'e' )  //clears screen and resets the script
  {
   gestion_espacement();
}
  
    if ( key == 'n' )  //n create new graphe
  {
    demo=false;
  //  messageInterface="Glissez le bouton \"Particule\" dans l'espace de travail pour créer une nouvelle particule";
    initialize();
   // initialise_defaut();
    initialiseZoom();
    loop();
    i0 = 0;
    running = true;
    return;
  }
      if ( key == 'b' )  //n create new graphe
  {
    demo=false;
  //  messageInterface="Glissez le bouton \"Particule\" dans l'espace de travail pour créer une nouvelle particule";
    initialize();
    initialiseZoom();
    loop();
    i0 = 0;
    running = true;
    return;
  }
      if ( key == 'd' )  //n afficher le graphe de démo
  {
    demo=true;
    initialize();
    loop();
    i0 = 0;
    running = true;
    return;
  }

  if (key == 's')   //saves a jpeg of the screen when the s key is pressed
  {
    saveFrame ("nodes-####.jpg");
  }
  //if (key == 'r') pdfoutput = true;
}

void mouseDragged( ) {
  xo = xo +(mouseX - pmouseX);
  yo = yo+(mouseY - pmouseY);
}



void mousePressed()
{ //println("mousePressed()");
  i0 = 0;
console.log(mouseX+" "+mouseY+" " +width+" "+height);
  if (runStateButton.over())
  {
    running = !running;
    if (running)
    {
      loop();
      return;
    } else
    { 
      i0 = SOMEdelay; // let draw() put us to sleep
      return;
    }
  }    

  if (startPauseButton.over())    
  {
    genning = !genning;
    if (genning)
    { 
      running = true;
      loop();
    }  
    if (!running)
    { 
      running = true;
      i0 = SOMEdelay;
      loop();
    }  
    return;
  }
/*
Gerer differemment l'ouverture de fichiers
  if (fichierButton.over())    
  {
    genning = !genning;
    if (genning)
    { 
      println("fichier button genning");
      selectInput("Select a file to process:", "fileSelected");

      running = true;
      loop();
    }  
    if (!running)
    { 
      println("fichier button running");
      //  running = true;
      //  i0 = SOMEdelay;
      loop();
    }  
    return;
  }
*/
  if (restartButton.over())
  {
    physics = new ParticleSystem( 0, 1.0 );
    centroid = new Smoother3D( 0.8 );
    initialize();
    if (!running)
    { 
      running = true;
      i0 = SOMEdelay;
      loop();
    }  
    return;
  }  

  // addNode();

  running = true;
  loop();
}  
