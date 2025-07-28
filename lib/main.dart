// Gerekli import'lar
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaman Bazlı Müzik',
      locale: Locale('tr', 'TR'),
      supportedLocales: [Locale('tr', 'TR'), Locale('en', 'US')],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
      home: MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Song {
  final String title;
  final String artist;
  final String duration;
  final String url; // Müzik URL'i eklendi
  final String coverUrl; // Kapak resmi URL'i

  Song({
    required this.title,
    required this.artist,
    required this.duration,
    required this.url,
    required this.coverUrl,
  });
}

class MoodRecommendation {
  final String mood;
  final String description;
  final List<Song> songs;

  MoodRecommendation({
    required this.mood,
    required this.description,
    required this.songs,
  });
}

class MusicHomePage extends StatefulWidget {
  @override
  _MusicHomePageState createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage>
    with TickerProviderStateMixin {
  DateTime currentTime = DateTime.now();
  bool isPlaying = false;
  bool isLoading = false;
  int currentSongIndex = 0;
  Timer? timer;
  Timer? progressTimer;

  // Müzik çalar durumu
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isShuffleOn = false;
  bool isRepeatOn = false;

  late AnimationController _sunMoonController;
  late AnimationController _playButtonController;
  late AnimationController _loadingController;
  PlayerState _playerState = PlayerState.stopped;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    // Animasyon kontrolcüleri
    _sunMoonController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _playButtonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Gerçek zamanlı saat güncellemesi
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateTime.now();
      });
    });

    _sunMoonController.repeat();
    _initializeAudio();

    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _playerState = state;
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if (isRepeatOn) {
        _playMusic(); // Aynı şarkıyı tekrar çal
      } else {
        // Sonraki şarkıya geç (otomatik çal)
        _nextSongAuto();
      }
    });
  }

  void _initializeAudio() {
    // Müzik durumu güncellemeleri için timer
    progressTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (isPlaying) {
        _updateProgress();
      }
    });
  }

  void _updateProgress() {
    // Simüle edilmiş ilerleme (gerçek audioplayers'da otomatik gelir)
    if (isPlaying && currentPosition < totalDuration) {
      setState(() {
        currentPosition = Duration(
          milliseconds: currentPosition.inMilliseconds + 500,
        );
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose(); // AudioPlayer'ı temizle
    timer?.cancel();
    progressTimer?.cancel();
    _sunMoonController.dispose();
    _playButtonController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  MoodRecommendation getMusicRecommendations(int hour) {
    if (hour >= 5 && hour < 9) {
      return MoodRecommendation(
        mood: "Sabah Enerjisi",
        description: "Güne başlarken motivasyon veren şarkılar",
        songs: [
          Song(
            title: "Good Morning",
            artist: "Kanye West",
            duration: "3:15",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FFD700/000000?text=Morning",
          ),
          Song(
            title: "Walking on Sunshine",
            artist: "Katrina & The Waves",
            duration: "3:58",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FFA500/000000?text=Sunshine",
          ),
          Song(
            title: "Here Comes the Sun",
            artist: "The Beatles",
            duration: "3:05",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FFD700/000000?text=Sun",
          ),
          Song(
            title: "Beautiful Day",
            artist: "U2",
            duration: "4:06",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/87CEEB/000000?text=Beautiful",
          ),
        ],
      );
    } else if (hour >= 9 && hour < 12) {
      return MoodRecommendation(
        mood: "Aktif Sabah",
        description: "Odaklanmaya yardımcı pozitif şarkılar",
        songs: [
          Song(
            title: "Uptown Funk",
            artist: "Mark Ronson ft. Bruno Mars",
            duration: "4:30",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FF69B4/000000?text=Funk",
          ),
          Song(
            title: "Can't Stop the Feeling",
            artist: "Justin Timberlake",
            duration: "3:56",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/32CD32/000000?text=Feeling",
          ),
          Song(
            title: "Happy",
            artist: "Pharrell Williams",
            duration: "3:53",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FFD700/000000?text=Happy",
          ),
          Song(
            title: "Shake It Off",
            artist: "Taylor Swift",
            duration: "3:39",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FF1493/000000?text=Shake",
          ),
        ],
      );
    } else if (hour >= 12 && hour < 17) {
      return MoodRecommendation(
        mood: "Öğleden Sonra",
        description: "Günün ortasında dinlendirici ritimler",
        songs: [
          Song(
            title: "Counting Stars",
            artist: "OneRepublic",
            duration: "4:17",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/4169E1/FFFFFF?text=Stars",
          ),
          Song(
            title: "Viva La Vida",
            artist: "Coldplay",
            duration: "4:01",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/9370DB/FFFFFF?text=Vida",
          ),
          Song(
            title: "Sunflower",
            artist: "Post Malone & Swae Lee",
            duration: "2:38",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FFD700/000000?text=Sunflower",
          ),
          Song(
            title: "Blinding Lights",
            artist: "The Weeknd",
            duration: "3:20",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FF00FF/000000?text=Lights",
          ),
        ],
      );
    } else if (hour >= 17 && hour < 21) {
      return MoodRecommendation(
        mood: "Akşam Keyfi",
        description: "Günün stresini atan rahatlatıcı şarkılar",
        songs: [
          Song(
            title: "Chill Bill",
            artist: "Rob \$tone",
            duration: "3:28",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/20B2AA/000000?text=Chill",
          ),
          Song(
            title: "Stay With Me",
            artist: "Sam Smith",
            duration: "2:52",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/CD5C5C/FFFFFF?text=Stay",
          ),
          Song(
            title: "Someone Like You",
            artist: "Adele",
            duration: "4:45",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/708090/FFFFFF?text=Someone",
          ),
          Song(
            title: "Perfect",
            artist: "Ed Sheeran",
            duration: "4:23",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/FF6347/FFFFFF?text=Perfect",
          ),
        ],
      );
    } else {
      return MoodRecommendation(
        mood: "Gece Dinginliği",
        description: "Sakin gece için huzur veren melodi",
        songs: [
          Song(
            title: "Mad World",
            artist: "Gary Jules",
            duration: "3:07",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-17.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/2F4F4F/FFFFFF?text=Mad",
          ),
          Song(
            title: "The Night We Met",
            artist: "Lord Huron",
            duration: "3:28",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-18.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/191970/FFFFFF?text=Night",
          ),
          Song(
            title: "Skinny Love",
            artist: "Bon Iver",
            duration: "3:58",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-19.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/696969/FFFFFF?text=Love",
          ),
          Song(
            title: "Hallelujah",
            artist: "Jeff Buckley",
            duration: "6:53",
            url:
                "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-20.mp3",
            coverUrl:
                "https://via.placeholder.com/300x300/4682B4/FFFFFF?text=Hallelujah",
          ),
        ],
      );
    }
  }

  // Müzik çalma fonksiyonları
  Future<void> _playPause() async {
    if (_playerState == PlayerState.playing) {
      await _pauseMusic();
    } else if (_playerState == PlayerState.paused) {
      await _resumeMusic();
    } else {
      await _playMusic();
    }
  }

  Future<void> _playMusic() async {
    try {
      setState(() {
        isLoading = true;
      });

      _loadingController.repeat();

      final currentSong = getMusicRecommendations(
        currentTime.hour,
      ).songs[currentSongIndex];

      // Müzik dosyasını çal
      await audioPlayer.play(UrlSource(currentSong.url));

      setState(() {
        isLoading = false;
        isPlaying = true;
      });

      _loadingController.stop();
      _playButtonController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _loadingController.stop();

      // Hata durumunda kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Müzik çalınamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pauseMusic() async {
    try {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
      _playButtonController.reverse();
    } catch (e) {
      print('Müzik duraklatılamadı: $e');
    }
  }

  Future<void> _stopMusic() async {
    try {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
      _playButtonController.reverse();
    } catch (e) {
      print('Müzik durdurulamadı: $e');
    }
  }

  Future<void> _resumeMusic() async {
    try {
      await audioPlayer.resume();
      setState(() {
        isPlaying = true;
      });
      _playButtonController.forward();
    } catch (e) {
      print('Müzik devam ettirilemedi: $e');
    }
  }

  Future<void> _nextSong() async {
    // Mevcut çalma durumunu kaydet
    bool wasPlaying = (_playerState == PlayerState.playing || isPlaying);

    await _stopMusic();
    setState(() {
      if (isShuffleOn) {
        currentSongIndex = Random().nextInt(
          getMusicRecommendations(currentTime.hour).songs.length,
        );
      } else {
        currentSongIndex =
            (currentSongIndex + 1) %
            getMusicRecommendations(currentTime.hour).songs.length;
      }
    });

    // Her zaman otomatik çal (kullanıcı butona bastığında)
    // veya müzik çalıyorsa otomatik devam et
    if (wasPlaying) {
      await _playMusic();
    }
  }

  Future<void> _previousSong() async {
    // Mevcut çalma durumunu kaydet
    bool wasPlaying = (_playerState == PlayerState.playing || isPlaying);

    await _stopMusic();
    setState(() {
      currentSongIndex =
          (currentSongIndex -
              1 +
              getMusicRecommendations(currentTime.hour).songs.length) %
          getMusicRecommendations(currentTime.hour).songs.length;
    });

    // Her zaman otomatik çal (kullanıcı butona bastığında)
    // veya müzik çalıyorsa otomatik devam et
    if (wasPlaying) {
      await _playMusic();
    }
  }

  // Sonraki şarkı (otomatik - şarkı bittiğinde)
  Future<void> _nextSongAuto() async {
    await _stopMusic();
    setState(() {
      if (isShuffleOn) {
        currentSongIndex = Random().nextInt(
          getMusicRecommendations(currentTime.hour).songs.length,
        );
      } else {
        currentSongIndex =
            (currentSongIndex + 1) %
            getMusicRecommendations(currentTime.hour).songs.length;
      }
    });

    // Her zaman yeni şarkıyı başlat
    await _playMusic();
  }

  void _seekTo(double seconds) async {
    try {
      final position = Duration(seconds: seconds.toInt());
      await audioPlayer.seek(position);
    } catch (e) {
      print('Arama yapılamadı: $e');
    }
  }

  Duration _parseDuration(String duration) {
    List<String> parts = duration.split(':');
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);
    return Duration(minutes: minutes, seconds: seconds);
  }

  Future<void> _playSongAt(int index) async {
    if (index == currentSongIndex && _playerState == PlayerState.playing) {
      await _pauseMusic();
    } else {
      await _stopMusic();
      setState(() {
        currentSongIndex = index;
      });
      await _playMusic();
    }
  }

  Color getSkyColor() {
    int hour = currentTime.hour;
    int minute = currentTime.minute;
    double totalMinutes = hour * 60.0 + minute;

    double sunrise = 6 * 60;
    double sunset = 18 * 60;

    if (totalMinutes >= sunrise && totalMinutes <= sunset) {
      double dayProgress = (totalMinutes - sunrise) / (sunset - sunrise);
      double hue = 200 + (dayProgress * 60);
      double lightness = 0.7 + (sin(dayProgress * pi) * 0.2);
      return HSVColor.fromAHSV(1.0, hue, 0.6, lightness).toColor();
    } else {
      return Color.fromRGBO(25, 25, 50, 1.0);
    }
  }

  bool isDay() {
    int hour = currentTime.hour;
    return hour >= 6 && hour < 18;
  }

  double getSunMoonPosition() {
    int hour = currentTime.hour;
    int minute = currentTime.minute;
    double totalMinutes = hour * 60.0 + minute;

    if (isDay()) {
      double sunrise = 6 * 60;
      double sunset = 18 * 60;
      return (totalMinutes - sunrise) / (sunset - sunrise);
    } else {
      double nightStart = 18 * 60;
      double nightEnd = 6 * 60 + 24 * 60;
      double adjustedTime = totalMinutes > 18 * 60
          ? totalMinutes
          : totalMinutes + 24 * 60;
      return (adjustedTime - nightStart) / (nightEnd - nightStart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = getMusicRecommendations(currentTime.hour);
    final skyColor = getSkyColor();
    final sunMoonPosition = getSunMoonPosition();
    final currentSong = recommendations.songs[currentSongIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [skyColor, skyColor.withOpacity(0.8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Gökyüzü Bölümü
              Container(
                height: 200,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Güneş/Ay
                    AnimatedPositioned(
                      duration: Duration(seconds: 1),
                      left:
                          MediaQuery.of(context).size.width *
                              (sunMoonPosition * 0.8 + 0.1) -
                          32,
                      top: 50 - (sin(sunMoonPosition * pi) * 30),
                      child: AnimatedBuilder(
                        animation: _sunMoonController,
                        builder: (context, child) {
                          return Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDay()
                                  ? Colors.yellow[400]
                                  : Colors.grey[200],
                              boxShadow: [
                                BoxShadow(
                                  color: isDay()
                                      ? Colors.yellow.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: isDay()
                                ? Container(
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow[300],
                                    ),
                                  )
                                : Container(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          left: 16,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),

                    // Yıldızlar (sadece gece)
                    if (!isDay()) ...[
                      Positioned(top: 30, left: 80, child: _buildStar()),
                      Positioned(top: 60, right: 120, child: _buildStar()),
                      Positioned(top: 45, right: 60, child: _buildStar()),
                      Positioned(
                        top: 80,
                        left: MediaQuery.of(context).size.width / 2,
                        child: _buildStar(),
                      ),
                    ],

                    // Saat Göstergesi
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Ana İçerik
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Mood Başlığı
                      Column(
                        children: [
                          Text(
                            recommendations.mood,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            recommendations.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Şu An Çalan Kartı
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Albüm Kapağı
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.purple[400]!,
                                            Colors.pink[400]!,
                                          ],
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          currentSong.coverUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.music_note,
                                                  color: Colors.white,
                                                  size: 30,
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentSong.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            currentSong.artist,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),

                                // Progress Bar
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          currentSong.duration,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 3,
                                        thumbColor: Colors.white,
                                        activeTrackColor: Colors.white,
                                        inactiveTrackColor: Colors.white
                                            .withOpacity(0.3),
                                        thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 6,
                                        ),
                                      ),
                                      child: Slider(
                                        value: totalDuration.inSeconds > 0
                                            ? currentPosition.inSeconds
                                                      .toDouble() /
                                                  totalDuration.inSeconds
                                                      .toDouble()
                                            : 0.0,
                                        onChanged: (value) {
                                          _seekTo(
                                            value * totalDuration.inSeconds,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),

                                // Kontroller
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isShuffleOn = !isShuffleOn;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.shuffle,
                                        color: isShuffleOn
                                            ? Colors.amber
                                            : Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _previousSong(),
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _playPause,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: isLoading
                                            ? AnimatedBuilder(
                                                animation: _loadingController,
                                                builder: (context, child) {
                                                  return Transform.rotate(
                                                    angle:
                                                        _loadingController
                                                            .value *
                                                        2 *
                                                        pi,
                                                    child: Icon(
                                                      Icons.refresh,
                                                      color: Colors.black,
                                                      size: 30,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Icon(
                                                isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _nextSong(),
                                      icon: Icon(
                                        Icons.skip_next,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isRepeatOn = !isRepeatOn;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.repeat,
                                        color: isRepeatOn
                                            ? Colors.amber
                                            : Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Önerilen Şarkılar
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Önerilen Şarkılar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: recommendations.songs.length,
                                  itemBuilder: (context, index) {
                                    final song = recommendations.songs[index];
                                    final isCurrentSong =
                                        index == currentSongIndex;

                                    return GestureDetector(
                                      onTap: () => _playSongAt(index),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isCurrentSong
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue[400]!,
                                                    Colors.purple[400]!,
                                                  ],
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  song.coverUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Center(
                                                          child: Text(
                                                            "${index + 1}",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    song.title,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    song.artist,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Çalan şarkı göstergesi
                                            if (isCurrentSong && isPlaying)
                                              Container(
                                                margin: EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: _buildPlayingIndicator(),
                                              ),
                                            Text(
                                              song.duration,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.6,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStar() {
    return AnimatedBuilder(
      animation: _sunMoonController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (sin(_sunMoonController.value * 2 * pi) * 0.5),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _sunMoonController,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(right: 2),
              width: 3,
              height: 12 + (sin(_sunMoonController.value * 2 * pi + index) * 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
