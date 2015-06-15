describe Calabash::Android::Device do
  let(:dummy_device_class) {Class.new(Calabash::Android::Device) {def initialize; @logger = Calabash::Logger.new; end}}
  let(:dummy_device) {dummy_device_class.new}
  let(:dummy_http_class) {Class.new(Calabash::HTTP::RetriableClient) {def initialize; end}}
  let(:dummy_http) {dummy_http_class.new}

  before do
    allow(dummy_device).to receive(:http_client).and_return(dummy_http)
  end

  it 'should inherit from Calabash::Device' do
    expect(Calabash::Android::Device.ancestors).to include(Calabash::Device)
  end

  describe '#default_serial' do
    it 'should fail if no devices are connected' do
      expect(dummy_device_class).to receive(:list_serials).and_return([])

      expect{dummy_device_class.default_serial}.to raise_error('No devices visible on adb. Ensure a device is visible in `adb devices`')
    end

    it 'should fail if more than one device are connected' do
      expect(dummy_device_class).to receive(:list_serials).and_return(['a', 'b'])

      expect{dummy_device_class.default_serial}.to raise_error('More than one device connected. Use $CAL_IDENTIFIER to select serial')
    end

    it 'should return the serial if only one device is connected' do
      expect(dummy_device_class).to receive(:list_serials).and_return(['my-serial'])

      expect(dummy_device_class.default_serial).to eq('my-serial')
    end
  end

  describe '#list_serials' do
    it 'should be able to list all connected serials' do
      devices = ['abcdefg123465abc', 'abcdefg123-ad---465abc', '2.2:abda', 'a', '55:555:55.555.555:55']

      expect(Calabash::Android::ADB).to receive(:command).with('devices').and_return(<<eos
**Daemon not running**
**Starting adb
List of devices attached
#{devices[0]}	device
#{devices[1]}	device
#{devices[2]}	device
#{devices[3]}	device
#{devices[4]}	device
eos
)

      expect(dummy_device_class.list_serials).to eq(devices)
    end
  end

  describe '#installed_packages' do
    it 'should be able to list installed packages' do
      allow(dummy_device.adb).to receive(:shell).with('pm list packages').and_return("package:com.myapp2.app\npackage:com.android.androidapp\npackage:com.app\n")

      expect(dummy_device.installed_packages).to eq([
                                                    'com.myapp2.app',
                                                    'com.android.androidapp',
                                                    'com.app'
                                                ])
    end
  end

  describe '#_clear_app_data' do
    let(:package) { 'com.myapp.package' }
    let(:dummy_app) { Class.new { def identifier; 'com.myapp.package'; end }.new }
    it 'should clear the app using adb' do
      expect(dummy_device).to receive(:installed_packages).and_return([package])
      expect(dummy_device.adb).to receive(:shell).with("pm clear #{package}").
         and_return("Success\n")

      dummy_device.send(:_clear_app_data, dummy_app)
    end
  end

  describe '#test_server_responding?' do
    let(:dummy_http_response_class) {Class.new {def body; end}}
    let(:dummy_http_response) {dummy_http_response_class.new}

    it 'should return false when a Calabash:HTTP::Error is raised' do
      allow(dummy_device.http_client).to receive(:get).and_raise(Calabash::HTTP::Error)

      expect(dummy_device.test_server_responding?).to be == false
    end

    it 'should return false when ping does not respond pong' do
      allow(dummy_http_response).to receive(:body).and_return('not_pong')
      allow(dummy_device.http_client).to receive(:get).and_return(dummy_http_response)

      expect(dummy_device.test_server_responding?).to be == false
    end

    it 'should return true when ping responds pong' do
      allow(dummy_http_response).to receive(:body).and_return('pong')
      allow(dummy_device.http_client).to receive(:get).and_return(dummy_http_response)

      expect(dummy_device.test_server_responding?).to be == true
    end
  end

  describe '#port_forward' do
    let(:host_port) {:my_host_port}

    describe 'when running in a managed environment' do
      it 'should invoke the managed impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(true)
        expect(dummy_device).not_to receive(:_port_forward)
        expect(Calabash::Managed).to receive(:port_forward).with(host_port, dummy_device)

        dummy_device.port_forward(host_port)
      end
    end

    describe 'when running in an unmanaged environment' do
      it 'should invoke the impl' do
        allow(Calabash::Managed).to receive(:managed?).and_return(false)
        expect(dummy_device).to receive(:port_forward).with(host_port)
        expect(Calabash::Managed).not_to receive(:port_forward)

        dummy_device.port_forward(host_port)
      end
    end
  end

  describe '#_port_forward' do
    it 'should use adb to forward the host port to the server port' do
      host_port = 12345

      dummy_server = Class.new {def test_server_port; 67890; end}.new

      allow(dummy_device).to receive(:server).and_return(dummy_server)

      expect(Calabash::Android::ADB).to receive(:command).with('forward', "tcp:#{host_port}", 'tcp:67890')

      dummy_device.send(:_port_forward, host_port)
    end
  end
end
