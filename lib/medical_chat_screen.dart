import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class HealthChatScreen extends StatefulWidget {
  const HealthChatScreen({Key? key}) : super(key: key);

  @override
  _HealthChatScreenState createState() => _HealthChatScreenState();
}

class _HealthChatScreenState extends State<HealthChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

 String _getMedicalContext(String question) {
  return '''
As a medical AI assistant trained on comprehensive healthcare knowledge, I can help answer health-related questions. $question

SECTION 1: GENERAL MEDICINE AND EMERGENCY CARE

Emergency Recognition & Response:
- Heart Attack Signs: chest pain/pressure, shortness of breath, pain radiating to arm/jaw/back, nausea, cold sweats, lightheadedness
- Stroke Symptoms (BE-FAST): Balance issues, Eyes (vision problems), Face drooping, Arm weakness, Speech difficulty, Time to call emergency
- Severe Allergic Reaction: throat tightness, wheezing, widespread hives, rapid pulse, dizziness, swelling of face/tongue
- Head Injury Red Flags: loss of consciousness, repeated vomiting, worsening headache, confusion, unequal pupils, clear fluid from nose/ears
- Breathing Emergency: gasping, blue lips/fingertips, inability to speak full sentences, severe chest tightness, rapid shallow breathing
- Severe Bleeding: apply direct pressure, elevate wound if possible, use clean cloth/gauze, seek immediate medical care
- Poisoning: call poison control, save container/substance, do not induce vomiting without professional guidance

Vital Signs & Basic Assessment:
- Blood Pressure Categories:
  * Normal: Below 120/80 mmHg
  * Elevated: 120-129/<80 mmHg
  * Stage 1 Hypertension: 130-139/80-89 mmHg
  * Stage 2 Hypertension: 140+/90+ mmHg
  * Crisis: 180+/120+ mmHg
- Heart Rate Ranges:
  * Adults resting: 60-100 bpm
  * Athletes resting: 40-60 bpm
  * Children (3-12 years): 70-110 bpm
  * Infants: 100-160 bpm
- Respiratory Rate:
  * Adults: 12-20 breaths/minute
  * Children: 20-30 breaths/minute
  * Infants: 30-60 breaths/minute
- Body Temperature:
  * Normal: 97.8-99°F (36.5-37.2°C)
  * Mild Fever: 99.1-100.4°F (37.3-38°C)
  * Moderate Fever: 100.4-102.2°F (38-39°C)
  * High Fever: >102.2°F (39°C)

SECTION 2: CHRONIC CONDITIONS MANAGEMENT

Diabetes Care:
- Type 1 Diabetes:
  * Insulin dependency
  * Blood sugar monitoring 4-10 times daily
  * Carbohydrate counting
  * Hypoglycemia prevention
  * Regular A1C testing
- Type 2 Diabetes:
  * Target blood sugar ranges:
    - Fasting: 80-130 mg/dL
    - 2 hours post-meal: <180 mg/dL
    - A1C: <7%
  * Lifestyle modifications
  * Medication compliance
  * Foot care and daily inspections
  * Regular eye examinations

Heart Disease Management:
- Coronary Artery Disease:
  * Medication adherence
  * Blood pressure monitoring
  * Cholesterol management
  * Exercise limitations
  * Dietary restrictions
- Heart Failure:
  * Daily weight monitoring
  * Fluid restriction
  * Salt limitation
  * Activity pacing
  * Symptom tracking

Respiratory Conditions:
- Asthma Management:
  * Peak flow monitoring
  * Trigger identification
  * Action plan levels
  * Inhaler technique
  * Emergency medication use
- COPD Care:
  * Breathing exercises
  * Energy conservation
  * Inhaler schedules
  * Oxygen therapy
  * Exacerbation prevention

SECTION 3: PREVENTIVE CARE & WELLNESS

Nutrition Guidelines:
- Macronutrient Distribution:
  * Carbohydrates: 45-65% of calories
  * Protein: 10-35% of calories
  * Fat: 20-35% of calories
- Daily Recommendations:
  * Fiber: 25-30g
  * Water: 2.7-3.7 liters
  * Sodium: <2300mg
  * Added sugars: <50g
- Vitamin Requirements:
  * Vitamin D: 600-800 IU
  * Vitamin B12: 2.4 mcg
  * Vitamin C: 65-90 mg
  * Calcium: 1000-1200 mg
  * Iron: 8-18 mg

Exercise Recommendations:
- Aerobic Activity:
  * Moderate: 150 minutes/week
  * Vigorous: 75 minutes/week
  * Target heart rate zones
  * Activity progression
- Strength Training:
  * 2-3 sessions/week
  * Major muscle groups
  * Proper form emphasis
  * Recovery periods
- Flexibility:
  * Daily stretching
  * Joint mobility
  * Range of motion
  * Injury prevention

SECTION 4: MENTAL HEALTH & BEHAVIORAL MEDICINE

Depression:
- Major Symptoms:
  * Persistent sadness
  * Loss of interest
  * Sleep changes
  * Appetite changes
  * Concentration issues
  * Energy loss
  * Worthlessness feelings
  * Suicidal thoughts
- Treatment Approaches:
  * Psychotherapy types
  * Medication options
  * Lifestyle modifications
  * Support systems
  * Crisis resources

Anxiety Disorders:
- Common Types:
  * Generalized Anxiety
  * Panic Disorder
  * Social Anxiety
  * Specific Phobias
- Management Strategies:
  * Breathing techniques
  * Cognitive restructuring
  * Exposure therapy
  * Medication options
  * Lifestyle changes

SECTION 5: SPECIALIZED CARE

Women's Health:
- Reproductive Health:
  * Menstrual cycle tracking
  * Contraception options
  * Fertility awareness
  * Menopause management
- Pregnancy Care:
  * Prenatal vitamins
  * Exercise guidelines
  * Diet restrictions
  * Warning signs
  * Labor stages
- Preventive Screenings:
  * Mammogram timing
  * Pap smear frequency
  * Bone density testing
  * HPV vaccination
  * Breast self-exams

Men's Health:
- Prostate Health:
  * PSA testing guidelines
  * Digital exam frequency
  * Warning symptoms
  * Treatment options
- Sexual Health:
  * ED evaluation
  * Testosterone testing
  * STI screening
  * Fertility testing
- Cancer Screening:
  * Colorectal tests
  * Skin checks
  * Testicular exams
  * Risk assessment

SECTION 6: PEDIATRIC CARE

Child Development:
- Milestones By Age:
  * Motor skills
  * Language development
  * Social interactions
  * Cognitive abilities
- Vaccination Schedule:
  * Birth to 15 months
  * 4-6 years
  * 11-12 years
  * Catch-up scheduling
- Growth Monitoring:
  * Height percentiles
  * Weight tracking
  * BMI assessment
  * Development curves

Common Childhood Conditions:
- Infectious Diseases:
  * Hand-foot-mouth
  * Fifth disease
  * Chickenpox
  * Strep throat
- Behavioral Concerns:
  * ADHD assessment
  * Autism screening
  * Learning disabilities
  * Sleep disorders

SECTION 7: DIAGNOSTIC GUIDANCE

Laboratory Values:
- Complete Blood Count:
  * Hemoglobin: 12-16 g/dL
  * White blood cells: 4,500-11,000/μL
  * Platelets: 150,000-450,000/μL
- Metabolic Panel:
  * Sodium: 135-145 mEq/L
  * Potassium: 3.5-5.0 mEq/L
  * Glucose: 70-100 mg/dL
  * Creatinine: 0.7-1.3 mg/dL

Imaging Guidelines:
- X-ray Indications:
  * Bone injuries
  * Chest infections
  * Dental problems
  * Joint issues
- CT Scan Usage:
  * Head trauma
  * Abdominal pain
  * Cancer staging
  * Complex fractures
- MRI Applications:
  * Soft tissue injury
  * Neurological conditions
  * Joint problems
  * Spine issues

SECTION 8: MEDICATION INFORMATION

Common Medications:
- Pain Relief:
  * Acetaminophen dosing
  * NSAID guidelines
  * Narcotic precautions
  * Alternative options
- Antibiotics:
  * Common types
  * Usage guidelines
  * Resistance concerns
  * Side effects
- Chronic Disease Meds:
  * Blood pressure drugs
  * Diabetes medications
  * Asthma inhalers
  * Heart medications

Safety Considerations:
- Drug Interactions:
  * Food restrictions
  * Timing guidelines
  * Combination risks
  * Alcohol warnings
- Side Effect Management:
  * Common reactions
  * Warning signs
  * Reporting guidelines
  * Prevention strategies

SECTION 9: LIFESTYLE MEDICINE

Sleep Hygiene:
- Recommended Duration:
  * Adults: 7-9 hours
  * Teens: 8-10 hours
  * Children: 9-11 hours
  * Seniors: 7-8 hours
- Quality Improvement:
  * Bedroom environment
  * Sleep schedule
  * Evening routine
  * Lifestyle factors

Stress Management:
- Relaxation Techniques:
  * Deep breathing
  * Progressive relaxation
  * Guided imagery
  * Meditation
- Lifestyle Balance:
  * Time management
  * Work-life harmony
  * Social connections
  * Hobby engagement

Response Protocol:
1. Assess urgency of the question
2. Identify relevant medical categories
3. Provide evidence-based information
4. Include preventive recommendations
5. Emphasize safety considerations
6. Note when professional consultation is needed
SECTION 10: GERIATRIC CARE

Aging and Mobility:
- Mobility aids: canes, walkers, wheelchairs, etc.
- Balance exercises for fall prevention
- Strategies for maintaining independence
- Home modifications for safety

Cognitive Health:
- Recognizing dementia symptoms
  * Memory loss impacting daily life
  * Confusion with time or place
  * Difficulty with familiar tasks
  * Poor judgment
  * Withdrawal from work or social activities
- Brain health maintenance:
  * Mental exercises, social engagement
  * Physical exercise and balanced diet

SECTION 11: IMMUNOLOGY AND ALLERGY MANAGEMENT

Allergy Management:
- Avoidance of known allergens
- Regular use of antihistamines if recommended
- Emergency plan for severe reactions
- EpiPen use if prescribed

Immunization Guidelines:
- Routine vaccinations for children and adults
- Special immunizations for seniors (e.g., shingles, pneumonia)
- Vaccinations for travel purposes
- Booster requirements

Autoimmune Disorders:
- Common types: Rheumatoid Arthritis, Lupus, Multiple Sclerosis
- Symptom monitoring
- Medication adherence for immune suppression
- Lifestyle adaptations for comfort and function

SECTION 12: CANCER CARE

Early Detection:
- Regular screenings for high-risk groups
  * Breast, prostate, colorectal, skin cancer screenings
- Self-exams for unusual lumps or skin changes
- Blood tests for certain cancers (e.g., PSA for prostate)
  
Cancer Treatment Modalities:
- Surgery, radiation, chemotherapy, immunotherapy
- Managing side effects: fatigue, nausea, infection risk
- Importance of nutrition and hydration
- Follow-up and remission care

SECTION 13: REHABILITATION MEDICINE

Physical Rehabilitation:
- Importance of physical therapy after injury/surgery
- Strength, flexibility, and endurance exercises
- Gait training and functional movement retraining

Occupational Therapy:
- Strategies for performing daily tasks with limitations
- Adaptive tools for independence
- Modifying the home environment for accessibility

Speech and Cognitive Rehabilitation:
- Speech therapy for language and swallowing issues
- Cognitive exercises for brain injury recovery
- Social reintegration skills training

Essential Disclaimers:
This information is for educational purposes only and should not replace professional medical advice. Individual situations require personalized medical evaluation. In emergencies, contact emergency services immediately. Medical knowledge evolves continuously; consult healthcare providers for current, personalized recommendations. The AI assistant cannot diagnose conditions or prescribe treatments - it can only provide general health information and guidance.

When discussing health matters, it's important to note that this is general information and you should always consult healthcare professionals for personalized medical advice, diagnosis, or treatment.''';
}

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
      _error = null;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/distilbert-base-uncased-distilled-squad'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': {
            'question': message,
            'context': _getMedicalContext(message),
          },
          'parameters': {
            'max_answer_len': 100,
          },
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _messages.add(Message(
            content: data['answer'] ?? "I apologize, I couldn't generate a proper response. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString().contains('Model is loading')
            ? 'The AI model is warming up. Please try again in a few moments.'
            : 'Sorry, there was an error processing your request. Please try again.';
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_error != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _error != null) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your health question...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    enabled: !_isLoading,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}