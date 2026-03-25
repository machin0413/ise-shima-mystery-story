// Web Audio Player for Flutter Web
// HTML5 Audio APIを使用してBGMを再生する

window.FlutterAudioPlayer = {
  _audios: {},
  _bgmAudio: null,
  _bgmVolume: 0.6,
  _sfxVolume: 0.8,
  _isBgmEnabled: true,
  _isSfxEnabled: true,
  _currentBgmSrc: null,

  // BGMを再生
  playBgm: function(src, loop) {
    if (!this._isBgmEnabled) return;
    if (loop === undefined) loop = true;

    // 同じBGMが再生中なら何もしない
    if (this._bgmAudio && !this._bgmAudio.paused && this._currentBgmSrc === src) {
      return;
    }

    // 既存のBGMを停止
    if (this._bgmAudio) {
      this._bgmAudio.pause();
      this._bgmAudio.currentTime = 0;
    }

    this._currentBgmSrc = src;
    this._bgmAudio = new Audio(src);
    this._bgmAudio.loop = loop;
    this._bgmAudio.volume = this._bgmVolume;
    
    // ユーザーインタラクション後に再生を試みる
    var playPromise = this._bgmAudio.play();
    if (playPromise !== undefined) {
      playPromise.then(function() {
        console.log('BGM started: ' + src);
      }).catch(function(error) {
        console.log('BGM autoplay prevented: ' + error);
      });
    }
  },

  // BGMを停止
  stopBgm: function() {
    if (this._bgmAudio) {
      this._bgmAudio.pause();
      this._bgmAudio.currentTime = 0;
      this._currentBgmSrc = null;
    }
  },

  // BGMを一時停止
  pauseBgm: function() {
    if (this._bgmAudio) {
      this._bgmAudio.pause();
    }
  },

  // BGMを再開
  resumeBgm: function() {
    if (this._bgmAudio && this._isBgmEnabled) {
      this._bgmAudio.play().catch(function(e) {
        console.log('Resume failed: ' + e);
      });
    }
  },

  // BGMの有効/無効
  setBgmEnabled: function(enabled) {
    this._isBgmEnabled = enabled;
    if (!enabled) {
      this.pauseBgm();
    } else {
      this.resumeBgm();
    }
  },

  // BGMのボリューム設定
  setBgmVolume: function(volume) {
    this._bgmVolume = Math.max(0, Math.min(1, volume));
    if (this._bgmAudio) {
      this._bgmAudio.volume = this._bgmVolume;
    }
  },

  // SEを再生
  playSfx: function(src) {
    if (!this._isSfxEnabled) return;
    var sfx = new Audio(src);
    sfx.volume = this._sfxVolume;
    sfx.play().catch(function(e) {
      console.log('SFX play failed: ' + e);
    });
  },

  // SFXの有効/無効
  setSfxEnabled: function(enabled) {
    this._isSfxEnabled = enabled;
  },

  // SFXのボリューム設定
  setSfxVolume: function(volume) {
    this._sfxVolume = Math.max(0, Math.min(1, volume));
  },

  // 現在BGMが再生中か確認
  isBgmPlaying: function() {
    return this._bgmAudio && !this._bgmAudio.paused;
  }
};

console.log('FlutterAudioPlayer initialized');
