describe Calabash::Application do

  let(:app_path) { File.join(Dir.tmpdir, 'my.app') }

  describe '#default' do
    after do
      Calabash::Application.default = nil
    end

    it 'should be able to set its default application' do
      Calabash::Application.default = :my_app
    end

    it 'should be able to get its default application' do
      app = :my_app

      Calabash::Application.default = app

      expect(Calabash::Application.default).to eq(app)
    end
  end

  describe '.new' do
    it 'raises an error if app path does not exist' do
      expect(File).to receive(:exist?).with(app_path).and_return(false)
      expect { Calabash::Application.new(app_path) }.to raise_error RuntimeError
    end

    it 'raises an argument error if the app path is nil' do
      expect{Calabash::Application.new(nil)}.to raise_error(ArgumentError)
    end

    describe 'option handling' do
      before(:each) do
        expect(File).to receive(:exist?).with(app_path).and_return(true)
      end

      it 'respects the :identifier option' do
        options = { :identifier => 'com.xamarin.flappy-monkey' }
        app = Calabash::Application.new(app_path, options)
        expect(app.identifier).to be == options[:identifier]
      end
    end

    describe '#identifier' do
      let(:app) {Calabash::Application.new(app_path)}

      before(:each) do
        expect(File).to receive(:exist?).with(app_path).and_return(true)
      end

      it 'tries to extract the identifier if it is not set' do
        expect(app).to receive(:extract_identifier).once.and_return('my-identifier')

        2.times {app.identifier}
      end

      it 'will not extract the identifier if it is set' do
        identifier = 'my-id'
        app.instance_variable_set(:@identifier, identifier)

        expect(app).not_to receive(:extract_identifier)

        expect(app.identifier).to be == identifier
      end
    end
  end

  describe '.from_path' do
    let(:path) {:my_path}
    let(:app) {:my_app}

    it 'should return an Android::Application if the path is an .apk' do
      allow(File).to receive(:extname).with(path).and_return('.apk')

      expect(Calabash::Android::Application).to receive(:new).with(path, nil).and_return(app)

      expect(Calabash::Application.from_path(path)).to eq(app)
    end

    it 'should return an IOS::Application if the path is an .app' do
      allow(File).to receive(:extname).with(path).and_return('.app')

      expect(Calabash::IOS::Application).to receive(:new).with(path).and_return(app)

      expect(Calabash::Application.from_path(path)).to eq(app)
    end

    it 'should return an IOS::Application if the path is an .ipa' do
      allow(File).to receive(:extname).with(path).and_return('.ipa')

      expect(Calabash::IOS::Application).to receive(:new).with(path).and_return(app)

      expect(Calabash::Application.from_path(path)).to eq(app)
    end

    it 'should return an Application if the path is something else' do
      allow(File).to receive(:extname).with(path).and_return('.something')

      expect(Calabash::Application).to receive(:new).with(path).and_return(app)

      expect(Calabash::Application.from_path(path)).to eq(app)
    end
  end
end
