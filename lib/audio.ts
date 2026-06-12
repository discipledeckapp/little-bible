// Prefers warm English female voices over robotic defaults

export function getPreferredVoice(): SpeechSynthesisVoice | null {
  if (typeof window === 'undefined') return null;
  const voices = window.speechSynthesis.getVoices();
  if (!voices.length) return null;

  // Priority order: named warm voices → US English female → any English
  return (
    voices.find((v) => v.name === 'Samantha') ||                          // macOS/iOS
    voices.find((v) => v.name === 'Karen') ||                             // Australian
    voices.find((v) => v.name === 'Moira') ||                             // Irish
    voices.find((v) => v.name.includes('Google US English')) ||
    voices.find(
      (v) => v.lang === 'en-US' && v.name.toLowerCase().includes('female')
    ) ||
    voices.find((v) => v.lang === 'en-US') ||
    voices.find((v) => v.lang.startsWith('en')) ||
    voices[0] ||
    null
  );
}

export interface SpeakOptions {
  rate?: number;
  pitch?: number;
  onEnd?: () => void;
  onError?: () => void;
}

export function speakText(
  text: string,
  { rate = 0.82, pitch = 1.05, onEnd, onError }: SpeakOptions = {}
): void {
  if (!('speechSynthesis' in window)) return;
  window.speechSynthesis.cancel();

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.rate = rate;
  utterance.pitch = pitch;

  // Voices may load async — retry once if empty
  const trySpeak = () => {
    const voice = getPreferredVoice();
    if (voice) utterance.voice = voice;
    if (onEnd) utterance.onend = onEnd;
    if (onError) utterance.onerror = onError;
    window.speechSynthesis.speak(utterance);
  };

  if (window.speechSynthesis.getVoices().length === 0) {
    window.speechSynthesis.addEventListener('voiceschanged', trySpeak, { once: true });
  } else {
    trySpeak();
  }
}

export function stopSpeech(): void {
  if (typeof window !== 'undefined') {
    window.speechSynthesis?.cancel();
  }
}

export function isSpeechSupported(): boolean {
  return typeof window !== 'undefined' && 'speechSynthesis' in window;
}
