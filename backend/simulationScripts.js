const pursuitPoints = [
  { offsetSeconds: 0, latitude: 37.7749, longitude: -122.4194, speed: 18, accuracy: 6 },
  { offsetSeconds: 8, latitude: 37.7765, longitude: -122.4178, speed: 20, accuracy: 6 },
  { offsetSeconds: 16, latitude: 37.7783, longitude: -122.4161, speed: 22, accuracy: 6 },
  { offsetSeconds: 24, latitude: 37.7802, longitude: -122.4146, speed: 24, accuracy: 6 },
  { offsetSeconds: 32, latitude: 37.7819, longitude: -122.4122, speed: 26, accuracy: 6 },
  { offsetSeconds: 40, latitude: 37.7826, longitude: -122.4094, speed: 28, accuracy: 6 },
  { offsetSeconds: 48, latitude: 37.7814, longitude: -122.4066, speed: 24, accuracy: 6 },
  { offsetSeconds: 56, latitude: 37.7796, longitude: -122.4049, speed: 21, accuracy: 6 },
  { offsetSeconds: 64, latitude: 37.7774, longitude: -122.4057, speed: 23, accuracy: 6 },
  { offsetSeconds: 72, latitude: 37.7756, longitude: -122.4079, speed: 25, accuracy: 6 },
  { offsetSeconds: 84, latitude: 37.7742, longitude: -122.4108, speed: 27, accuracy: 6 },
  { offsetSeconds: 96, latitude: 37.7735, longitude: -122.4142, speed: 29, accuracy: 6 },
  { offsetSeconds: 110, latitude: 37.7743, longitude: -122.4175, speed: 26, accuracy: 6 },
];

const SIMULATION_SCRIPTS = {
  'pursuit-police': {
    id: 'pursuit-police',
    name: 'Police Pursuit',
    points: pursuitPoints,
  },
  'pursuit-police-follow': {
    id: 'pursuit-police-follow',
    name: 'Police Pursuit (Follow)',
    points: pursuitPoints,
  },
  'normal-driving': {
    id: 'normal-driving',
    name: 'Normal Driving',
    points: [
      { offsetSeconds: 0, latitude: 37.7749, longitude: -122.4194, speed: 12, accuracy: 8 },
      { offsetSeconds: 12, latitude: 37.7762, longitude: -122.4179, speed: 12, accuracy: 8 },
      { offsetSeconds: 24, latitude: 37.7778, longitude: -122.4161, speed: 13, accuracy: 8 },
      { offsetSeconds: 36, latitude: 37.7794, longitude: -122.4143, speed: 13, accuracy: 8 },
      { offsetSeconds: 48, latitude: 37.781, longitude: -122.4122, speed: 14, accuracy: 8 },
      { offsetSeconds: 60, latitude: 37.7826, longitude: -122.4102, speed: 14, accuracy: 8 },
      { offsetSeconds: 72, latitude: 37.7842, longitude: -122.4082, speed: 13, accuracy: 8 },
      { offsetSeconds: 84, latitude: 37.7858, longitude: -122.4063, speed: 12, accuracy: 8 },
    ],
  },
  'gps-jitter': {
    id: 'gps-jitter',
    name: 'GPS Jitter',
    points: [
      { offsetSeconds: 0, latitude: 37.7749, longitude: -122.4194, speed: 0.2, accuracy: 25 },
      { offsetSeconds: 6, latitude: 37.7750, longitude: -122.4195, speed: 0.2, accuracy: 35 },
      { offsetSeconds: 12, latitude: 37.7748, longitude: -122.4193, speed: 0.2, accuracy: 40 },
      { offsetSeconds: 18, latitude: 37.7751, longitude: -122.4196, speed: 0.2, accuracy: 30 },
      { offsetSeconds: 24, latitude: 37.7749, longitude: -122.4192, speed: 0.2, accuracy: 28 },
      { offsetSeconds: 30, latitude: 37.7750, longitude: -122.4194, speed: 0.2, accuracy: 32 },
    ],
  },
  'network-interruption': {
    id: 'network-interruption',
    name: 'Network Interruption',
    points: [
      { offsetSeconds: 0, latitude: 37.7749, longitude: -122.4194, speed: 10, accuracy: 12 },
      { offsetSeconds: 10, latitude: 37.7760, longitude: -122.4180, speed: 10, accuracy: 12 },
      { offsetSeconds: 20, latitude: 37.7773, longitude: -122.4164, speed: 11, accuracy: 12 },
      { offsetSeconds: 45, latitude: 37.7790, longitude: -122.4142, speed: 11, accuracy: 12 },
      { offsetSeconds: 55, latitude: 37.7808, longitude: -122.4120, speed: 11, accuracy: 12 },
      { offsetSeconds: 65, latitude: 37.7824, longitude: -122.4102, speed: 11, accuracy: 12 },
    ],
  },
};

function listScripts() {
  return Object.values(SIMULATION_SCRIPTS).map(({ id, name }) => ({ id, name }));
}

function getScript(scriptId) {
  return SIMULATION_SCRIPTS[scriptId] || null;
}

module.exports = { listScripts, getScript };
