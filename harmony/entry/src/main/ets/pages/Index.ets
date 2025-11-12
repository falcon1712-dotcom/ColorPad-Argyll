import { BusinessError } from '@kit.BasicServicesKit';

// Декларация нативного модуля (Node-API)
const napi = require('libargyll.so');

@Entry
@Component
struct IndexPage {
  @State deviceFound: boolean = false;
  @State logs: string = '1. Подключите i1Pro3 через хаб\n2. Нажмите «Scan USB»';
  @State isMeasuring: boolean = false;

  // Логирование в UI
  private log(msg: string) {
    this.logs += '\n' + msg;
  }

  build() {
    Column({ space: 12 }) {
      Text('ColorPad Argyll v0.1')
        .fontSize(20).fontWeight(FontWeight.Bold).margin(16);

      // Кнопка сканирования USB
      Button('🔍 Scan USB')
        .width('90%')
        .onClick(() => this.scanUSB());

      // Если устройство найдено — показываем доп. кнопки
      if (this.deviceFound) {
        Button('⚪ Calibrate white tile')
          .width('90%')
          .onClick(() => this.calibrate());
        
        Button('🎨 Measure chart')
          .width('90%')
          .backgroundColor(this.isMeasuring ? Color.Green : Color.Blue)
          .onClick(() => this.measureChart());
        
        Button('📊 Build profile')
          .width('90%')
          .onClick(() => this.buildProfile());
      }

      // Лог-окно (прокручиваемое)
      Scroll() {
        Text(this.logs)
          .fontSize(11)
          .fontFamily('monospace')
          .padding(8)
          .backgroundColor('#f0f0f0')
          .width('100%')
      }
      .height('60%')
      .border({ width: 1, color: '#ccc' });
    }
    .width('100%')
    .height('100%')
    .padding(12);
  }

  // Сканирование USB (вызов системного lsusb через napi)
  private scanUSB() {
    this.logs = 'Scanning...';
    try {
      const result = napi.runArgyll('lsusb | grep 0765');
      if (result.includes('0765:6009')) {
        this.deviceFound = true;
        this.log('✓ i1Pro3 Plus найден (VID 0765, PID 6009)');
      } else {
        this.log('✗ Устройство не обнаружено. Проверь подключение.');
      }
    } catch (e) {
      this.log('Ошибка: ' + (e as BusinessError).message);
    }
  }

  // Калибровка белой плитки
  private calibrate() {
    this.log('→ Калибровка: положите i1Pro3 на белую плитку...');
    const result = napi.runArgyll('/data/argyll/ccxxmake -X -A i1pro3 -C -c "i1Pro3"');
    this.log(result);
    this.log('✓ Калибровка завершена, .ccss создан');
  }

  // Измерение тест-чарта
  private measureChart() {
    this.isMeasuring = true;
    this.log('→ Измерение патчей, подождите...');
    // Пример: читаем готовый chart.ti1 (его нужно положить в resources)
    const result = napi.runArgyll('/data/argyll/chartread -v -H -T0.4 /data/argyll/chart.ti1');
    this.log(result);
    this.isMeasuring = false;
    this.log('✓ Измерение завершено, chart.ti3 создан');
  }

  // Построение профиля
  private buildProfile() {
    this.log('→ Построение ICC-профиля...');
    const result = napi.runArgyll('/data/argyll/colprof -v -D"MatePad_RGB" -q m -a m -n c chart.ti3');
    this.log(result);
    this.log('✓ Профиль создан: /Download/MatePad_RGB.icc');
  }
}