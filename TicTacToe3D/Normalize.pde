boolean linear = true;
float minDistance = 1, maxDistance = 4;

class Normalize {
  float min, max;
  Normalize() {
    reset();
  }
  void note(float x) {
    if(x < min)
      min = x;
    if(x > max)
      max = x;
  }
  float normalize(float x) {
    if(min == max || min == Float.POSITIVE_INFINITY)
      return 0;
    float n = map(x, min, max, 0, 1);
    return constrain(n, 0, 1);
  }
  float linear(float x) {
    float normalized = normalize(x);
    if(normalized == 0)
      return 1;
    float linear = sqrt(1 / normalized);
    linear = map(linear, minDistance, maxDistance, 0, 1);
    //println(linear);
    return constrain(linear, 0, 1);
  }
  float choose(float x) {
    return linear ? linear(x) : normalize(x);
  }
  void reset() {
    min = Float.POSITIVE_INFINITY;
    max = Float.NEGATIVE_INFINITY;  
  }
}
