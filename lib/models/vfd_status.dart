class VfdStatus {
  final bool running;
  final int commandedSpeed;

  VfdStatus({
    required this.running,
    required this.commandedSpeed,
  });

  factory VfdStatus.fromJson(
    Map<String, dynamic> json,
  ) {
    return VfdStatus(
      running: json['running'] ?? false,
      commandedSpeed: json['speed'] ?? 0,
    );
  }
}
