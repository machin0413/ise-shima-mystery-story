// Web Audio Player for Flutter Web
// HTML5 Audio APIを使用してBGMを再生する

(function() {
  'use strict';

  window.FlutterAudioPlayer = {
    _bgmAudio: null,
    _bgmVolume: 0.6,
    _sfxVolume: 0.8,
    _isBgmEnabled: true,
    _isSfxEnabled: true,
    _currentBgmSrc: null,

    // BGMを再生
    playBgm: function(src, loop) {
      console.log('[FAP] playBgm called:', src, 'loop:', loop);
      
      if (!this._isBgmEnabled) {
        console.log('[FAP] BGM disabled, skipping');
        return;
      }
      if (loop === undefined) loop = true;

      // 同じBGMが再生中なら何もしない
      if (this._bgmAudio && !this._bgmAudio.paused && this._currentBgmSrc === src) {
        console.log('[FAP] Same BGM already playing, skipping');
        return;
      }

      // 既存のBGMを停止
      if (this._bgmAudio) {
        this._bgmAudio.pause();
        this._bgmAudio.currentTime = 0;
        this._bgmAudio = null;
      }

      try {
        this._currentBgmSrc = src;
        this._bgmAudio = new Audio(src);
        this._bgmAudio.loop = loop;
        this._bgmAudio.volume = this._bgmVolume;
        
        console.log('[FAP] Audio object created, attempting play...');
        
        var self = this;
        var playPromise = this._bgmAudio.play();
        if (playPromise !== undefined) {
          playPromise.then(function() {
            console.log('[FAP] BGM playing successfully:', src);
          }).catch(function(error) {
            console.warn('[FAP] BGM autoplay blocked:', error.message);
            // ユーザーインタラクション後に再試行するためのフラグ
            self._pendingPlay = true;
            
            // クリック/タップイベントで再生を再試行
            var retry = function() {
              if (self._pendingPlay && self._bgmAudio) {
                self._bgmAudio.play().then(function() {
                  console.log('[FAP] BGM started after user interaction');
                  self._pendingPlay = false;
                }).catch(function(e) {
                  console.error('[FAP] Retry failed:', e);
                });
              }
              document.removeEventListener('click', retry);
              document.removeEventListener('touchstart', retry);
              document.removeEventListener('keydown', retry);
            };
            document.addEventListener('click', retry, { once: true });
            document.addEventListener('touchstart', retry, { once: true });
            document.addEventListener('keydown', retry, { once: true });
          });
        }
      } catch (e) {
        console.error('[FAP] Error creating audio:', e);
      }
    },

    // BGMを停止
    stopBgm: function() {
      console.log('[FAP] stopBgm called');
      if (this._bgmAudio) {
        this._bgmAudio.pause();
        this._bgmAudio.currentTime = 0;
        this._bgmAudio = null;
        this._currentBgmSrc = null;
        this._pendingPlay = false;
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
          console.warn('[FAP] Resume failed:', e.message);
        });
      }
    },

    // BGMの有効/無効切り替え
    setBgmEnabled: function(enabled) {
      console.log('[FAP] setBgmEnabled:', enabled);
      this._isBgmEnabled = enabled;
      if (!enabled) {
        this.pauseBgm();
      } else if (this._bgmAudio) {
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
      try {
        var sfx = new Audio(src);
        sfx.volume = this._sfxVolume;
        sfx.play().catch(function(e) {
          console.warn('[FAP] SFX play failed:', e.message);
        });
      } catch (e) {
        console.error('[FAP] SFX error:', e);
      }
    },

    setSfxEnabled: function(enabled) {
      this._isSfxEnabled = enabled;
    },

    setSfxVolume: function(volume) {
      this._sfxVolume = Math.max(0, Math.min(1, volume));
    },

    isBgmPlaying: function() {
      return !!(this._bgmAudio && !this._bgmAudio.paused);
    }
  };

  console.log('[FAP] FlutterAudioPlayer initialized and ready');
})();
