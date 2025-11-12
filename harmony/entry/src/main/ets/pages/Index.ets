import libargyll from 'libargyll.so';

@Entry
@Component
struct IndexPage {
  @State deviceFound: boolean = false;
  @State logs: string = '1. Подключите i1Pro3 через хаб\n2. Нажмите «Scan USB»';
  @State isMeasuring: boolean = false;

  private log(msg: string) {
    this.logs += '\n' + msg;
  }

  build() {
    Column({ space: 12 }) {
      Text('ColorPad Argyll v0.1').fontSize(20).fontWeight(FontWeight.Bold).margin(16);
      Button('🔍 Scan USB').width('90%').onClick(() => this.scanUSB());
      
      if (this.deviceFound) {
        Button('⚪ Calibrate').width('90%').onClick(() => this.calibrate());
        Button('🎨 Measure').width('90%').backgroundColor(this.isMeasuring ? Color.Green : Color.Blue).onClick(() => this.measureChart());
        Button('📊 Build profile').width('90%').onClick(() => this.buildProfile());
      }

      Scroll() {
        Text(this.logs).fontSize(11).fontFamily('monospace').padding(8).backgroundColor('#f0f0f0').width('100%')
      }.height('60%').border({ width: 1, color: '#ccc' });
    }
    .width('100%').height('100%').padding(12);
  }

  private scanUSB() {
    this.logs = 'Scanning...';
    try {
      const result = libargyll.runArgyll('lsusb | grep 0765');
      if (result.includes('0765:6009')) {
        this.deviceFound = true;
        this.log('✓ i1Pro3 Plus найден');
      } else this.log('✗ Устройство не обнаружено');
    } catch (e) {
      this.log('Ошибка: ' + e.message);
    }
  }

  private calibrate() {
    this.log('→ Калибровка белой плитки...');
    const result = libargyll.runArgyll('/data/argyll/ccxxmake -X -A i1pro3');
    this.log(result);
    this.log('✓ Калибровка завершена');
  }

  private measureChart() {
    this.isMeasuring = true;
    this.log('→ Измерение патчей...');
    const result = libargyll.runArgyll('/data/argyll/chartread -v -H chart.ti1');
    this.log(result);
    this.isMeasuring = false;
    this.log('✓ Измерение завершено');
  }

  private buildProfile() {
    this.log('→ Построение профиля...');
    const result = libargyll.runArgyll('/data/argyll/colprof -v -D"MatePad" -q m chart.ti3');
    this.log(result);
    this.log('✓ Профиль создан');
  }
}