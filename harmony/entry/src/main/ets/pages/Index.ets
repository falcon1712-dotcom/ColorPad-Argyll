import libargyll from 'libargyll.so';

@Entry
@Component
struct IndexPage {
  @State deviceFound: boolean = false;
  @State logs: string = '1. Подключите i1Pro3\n2. Нажмите «Scan»';

  build() {
    Column({ space: 12 }) {
      Text('ColorPad Argyll v0.1').fontSize(20).fontWeight(FontWeight.Bold).margin(16);
      Button('🔍 Scan USB').width('90%').onClick(() => this.scanUSB());
      
      if (this.deviceFound) {
        Button('⚪ Calibrate').width('90%').onClick(() => this.calibrate());
        Button('🎨 Measure').width('90%').onClick(() => this.measure());
      }

      Scroll() {
        Text(this.logs).fontSize(11).fontFamily('monospace').padding(8).backgroundColor('#f0f0f0').width('100%')
      }.height('60%').border({ width: 1, color: '#ccc' });
    }.width('100%').height('100%').padding(12);
  }

  private scanUSB() {
    this.logs = 'Scanning...';
    try {
      const result = libargyll.runArgyll('lsusb | grep 0765');
      this.deviceFound = result.includes('0765:6009');
      this.logs = this.deviceFound ? '✓ i1Pro3 найден' : '✗ Устройство не найдено';
    } catch (e) {
      this.logs = 'Ошибка: ' + e.message;
    }
  }

  private calibrate() {
    this.logs = 'Калибровка...';
    const result = libargyll.runArgyll('ccxxmake -X');
    this.logs = result;
  }

  private measure() {
    this.logs = 'Измерение...';
    const result = libargyll.runArgyll('chartread -v chart.ti1');
    this.logs = result;
  }
}