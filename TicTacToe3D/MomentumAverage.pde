class MomentumAverage {
  float adapt;
  float avg;
  MomentumAverage(float adapt) {
    this.adapt = adapt;
    reset();
  }
  void note(float x) {
    if(x == Float.POSITIVE_INFINITY)
      return;
    else
      avg = (avg * (1 - adapt)) + (x * adapt);
  }
  void reset() {
    avg = 0;
  }
}
