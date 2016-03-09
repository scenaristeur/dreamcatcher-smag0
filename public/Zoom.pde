void zoomIn() {
  zoom += 1; //.10
  xo=xo-zoom*d;
  yo=yo-zoom*d;
}

void zoomOut() {
  zoom -= 1; //.10
  xo=xo+zoom*d;
  yo=yo+zoom*d;
}

void initialiseZoom() {
  d = 40;
  zoom = 1;
  angle = 0;
  xo = 0;
  yo = 0;
}

void appliqueZoom() {
  translate(xo, yo);
  scale(zoom);
  rotate(angle);
}
