import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'dart:io';

class LocalLLMService {
  Llama? _llama;
  bool _isLoaded = false;

  Future<void> loadModel(String modelPath) async {
    if (_isLoaded) return;
    if (!File(modelPath).existsSync()) {
      throw Exception('Model file not found at $modelPath');
    }

    try {
      _llama = Llama(modelPath);
      _isLoaded = true;
      print('[LLM] Native Qwen2.5 loaded successfully.');
    } catch (e) {
      throw Exception('Failed to load local model: $e');
    }
  }

  Future<String> extractJsonFromTranscript(String transcript, {String taskType = 'todo'}) async {
    if (!_isLoaded) {
      throw Exception('LLM Engine not loaded.');
    }

    String systemPrompt = '';
    
    if (taskType == 'chatInteraction') {
      systemPrompt = '''You are an expert CRM assistant that extracts structured conversation data from a voice transcript.
The user just dictated notes about a business conversation they had.
Extract the following fields into a strict JSON format (use null if missing):
- "contactName": Name of the person they spoke with.
- "contactPhone": Phone number if mentioned.
- "company": Company name.
- "projectName": The project or deal name.
- "dealAmount": Estimated deal value as a number (in INR). Parse "5 lakh" as 500000.
- "businessSize": The size of the business (e.g. Small, Medium, Enterprise).
- "summary": A clean 1-3 sentence summary of the conversation.
- "interestLevel": "hot", "warm", or "cold" based on tone/urgency.
- "contactType": "client", "lead", "employee", "associate", "supplier", or "other".
- "remarks": Any extra notes or observations.
- "revertBy": Follow-up date/time (YYYY-MM-DDTHH:mm) if mentioned.
- "actionables": Array of action items. Every task must have "title", "dueDate" (YYYY-MM-DD if mentioned), and "assignedTo" ("me" or a specific person).
Only return valid JSON, no conversational text or markdown formatting.''';
    } else if (taskType == 'businessContext') {
      systemPrompt = '''You are an expert business assistant. The user is dictating their business profile, target audience, and value proposition.
Analyze the voice note and extract a professional, concise summary.
Return ONLY a valid JSON object in this exact format:
{"businessContext": "The extracted professional summary in 2-3 sentences."}
No conversational text or markdown.''';
    } else {
      systemPrompt = '''You are an expert personal assistant. Analyze the given voice note.
Extract the task information into a strict JSON format. 
Return a JSON object with a single key "actionables" containing a list of tasks.
Every task must have:
- "title": A concise description of the task.
- "dueDate": (Optional) The deadline in ISO8601 format (YYYY-MM-DD) or a string timeline like "Tomorrow", if mentioned.
- "assignedTo": (Optional) The name of the person responsible. If the speaker implies they will do it, output "me".
Only return valid JSON, no conversational text.''';
    }

    final prompt = '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\nTranscript: $transcript<|im_end|>\n<|im_start|>assistant\n';

    try {
      _llama!.setPrompt(prompt);
      
      String generatedText = '';
      bool isDone = false;
      
      while (!isDone) {
        final (text, done) = _llama!.getNext();
        generatedText += text;
        isDone = done;
      }
      
      return generatedText;
    } catch (e) {
      print('[LLM] Generation error: $e');
      return '{"status": "error", "message": "Generation failed"}';
    }
  }

  Future<String> generateTriviaQuestion(String clientData) async {
    if (!_isLoaded) {
      throw Exception('LLM Engine not loaded.');
    }

    const systemPrompt = '''You are a Quizmaster. Read the client data.
Generate ONE multiple-choice trivia question about this client to test if the user remembers them.
Make it tricky but factual based on the data provided.

Return ONLY valid JSON in this exact format, with no markdown formatting or conversational text:
{"q": "The question text", "opts": ["Option 1", "Option 2", "Option 3"], "ans": 0}''';

    final prompt = '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\nClient Data:\n$clientData<|im_end|>\n<|im_start|>assistant\n';

    try {
      _llama!.setPrompt(prompt);
      
      String generatedText = '';
      bool isDone = false;
      
      while (!isDone) {
        final (text, done) = _llama!.getNext();
        generatedText += text;
        isDone = done;
      }
      
      return generatedText;
    } catch (e) {
      print('[LLM] Trivia generation error: $e');
      return '{"status": "error", "message": "Generation failed"}';
    }
  }

  Future<String> generateBusinessWisdom(String contextStr) async {
    if (!_isLoaded) {
      throw Exception('LLM Engine not loaded.');
    }

    const systemPrompt = '''You are an expert sales coach and business mentor. Provide ONE short, punchy, actionable piece of business wisdom or sales advice.
Base your advice loosely on the user's current context if provided.
Keep it under 3 sentences. Be motivational but practical.
Do NOT use markdown, quotes, emojis, or conversational filler. Start directly with the advice.''';

    final prompt = '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\nUser Context:\n$contextStr<|im_end|>\n<|im_start|>assistant\n';

    try {
      _llama!.setPrompt(prompt);
      
      String generatedText = '';
      bool isDone = false;
      
      while (!isDone) {
        final (text, done) = _llama!.getNext();
        generatedText += text;
        isDone = done;
      }
      
      return generatedText.trim().replaceAll('"', '');
    } catch (e) {
      print('[LLM] Wisdom generation error: $e');
      throw Exception('Generation failed');
    }
  }

  Future<String> generatePitchAnalysis(String pitchTranscript) async {
    if (!_isLoaded) {
      throw Exception('LLM Engine not loaded.');
    }

    const systemPrompt = '''You are an expert sales coach evaluating a trainee's sales pitch.
Analyze the pitch transcript provided. Evaluate it on:
- Clarity: Is the message clear?
- Value Proposition: Does it highlight benefits?
- Persuasiveness: Is it compelling?
- Confidence: Does the speaker sound assured?

Return ONLY valid JSON in this exact format with no markdown or extra text:
{"score": 72, "feedback": "Overall concise feedback in 2 sentences.", "strengths": ["Point 1", "Point 2"], "weaknesses": ["Point 1"]}
Score should be between 0 and 100.''';

    final prompt = '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\nPitch Transcript:\n$pitchTranscript<|im_end|>\n<|im_start|>assistant\n';

    try {
      _llama!.setPrompt(prompt);
      String generatedText = '';
      bool isDone = false;
      while (!isDone) {
        final (text, done) = _llama!.getNext();
        generatedText += text;
        isDone = done;
      }
      return generatedText;
    } catch (e) {
      print('[LLM] Pitch analysis error: $e');
      return '{"score": 0, "feedback": "Unable to analyze pitch.", "strengths": [], "weaknesses": ["Analysis failed"]}';
    }
  }

  void dispose() {
    _llama?.dispose();
    _isLoaded = false;
  }
}

final llmServiceProvider = Provider((ref) => LocalLLMService());
