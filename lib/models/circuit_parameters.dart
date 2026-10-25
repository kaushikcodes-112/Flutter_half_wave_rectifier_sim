class CircuitParameters {
  double voltage;
  double frequency;
  double resistance;
  double diodeVoltage;

  CircuitParameters({
    this.voltage = 10.0,
    this.frequency = 50.0,
    this.resistance = 1000.0,
    this.diodeVoltage = 0.7,
  });

  double get period => 1 / frequency;
}
