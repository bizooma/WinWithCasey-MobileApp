import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'video_player_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Education'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Section
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Know Your Rights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn about personal injury law, your rights, and the legal process to make informed decisions about your case.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Featured Videos
          Text(
            'Featured Videos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ondemand_video),
              title: const Text('What To Do After a Car Accident'),
              subtitle: const Text('Watch on YouTube'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                const url = 'https://www.youtube.com/watch?v=HJiX2YLw1rU';
                if (kIsWeb) {
                  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open YouTube.')),
                    );
                  }
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VideoPlayerScreen(
                        youtubeUrl: url,
                        title: 'What To Do After a Car Accident',
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          // Categories
          Text(
            'Educational Topics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Personal Injury Basics
          _EducationCategory(
            title: 'Personal Injury Basics',
            icon: Icons.info_outline,
            items: [
              _EducationItem(
                title: 'What is Personal Injury Law?',
                description: 'Understanding the fundamentals of personal injury claims',
                onTap: () => _showContent(context, personalInjuryBasics),
              ),
              _EducationItem(
                title: 'Types of Personal Injury Cases',
                description: 'Car accidents, slip and falls, medical malpractice, and more',
                onTap: () => _showContent(context, typesOfCases),
              ),
              _EducationItem(
                title: 'Statute of Limitations in Washington',
                description: 'Important deadlines for filing your claim',
                onTap: () => _showContent(context, statuteOfLimitations),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Your Rights
          _EducationCategory(
            title: 'Your Rights & Responsibilities',
            icon: Icons.gavel,
            items: [
              _EducationItem(
                title: 'Your Rights After an Accident',
                description: 'What you\'re entitled to and how to protect your interests',
                onTap: () => _showContent(context, yourRights),
              ),
              _EducationItem(
                title: 'Dealing with Insurance Companies',
                description: 'Do\'s and don\'ts when speaking with insurers',
                onTap: () => _showContent(context, insuranceDealing),
              ),
              _EducationItem(
                title: 'Medical Treatment Rights',
                description: 'Your right to choose your doctor and get proper care',
                onTap: () => _showContent(context, medicalRights),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Legal Process
          _EducationCategory(
            title: 'The Legal Process',
            icon: Icons.account_balance,
            items: [
              _EducationItem(
                title: 'How Personal Injury Cases Work',
                description: 'Step-by-step overview of the legal process',
                onTap: () => _showContent(context, legalProcess),
              ),
              _EducationItem(
                title: 'Settlement vs. Trial',
                description: 'Understanding your options for resolving your case',
                onTap: () => _showContent(context, settlementVsTrial),
              ),
              _EducationItem(
                title: 'Working with an Attorney',
                description: 'What to expect and how to maximize your relationship',
                onTap: () => _showContent(context, workingWithAttorney),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // FAQ Section
          _EducationCategory(
            title: 'Frequently Asked Questions',
            icon: Icons.help_outline,
            items: [
              _EducationItem(
                title: 'How much is my case worth?',
                description: 'Factors that affect case valuation',
                onTap: () => _showContent(context, caseValue),
              ),
              _EducationItem(
                title: 'How long will my case take?',
                description: 'Timeline expectations for personal injury cases',
                onTap: () => _showContent(context, caseTimeline),
              ),
              _EducationItem(
                title: 'What if I was partially at fault?',
                description: 'Understanding comparative negligence in Washington',
                onTap: () => _showContent(context, partialFault),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Contact Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Legal Help?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have questions about your specific case, contact our office for a free consultation.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _launchPhone(context),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call 253-499-8662'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContent(BuildContext context, Map<String, String> content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ContentScreen(
          title: content['title']!,
          content: content['content']!,
        ),
      ),
    );
  }

  void _contactAttorney(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Attorney'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: const Text('253-499-8662'),
              onTap: () {
                Navigator.pop(context);
                _launchPhone(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('joe@bizooma.com'),
              onTap: () {
                Navigator.pop(context);
                _launchEmail(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '2534998662');
    final ok = await launchUrl(uri);
    if (!ok) {
      _showSnack(context, 'Could not open phone dialer.');
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'joe@bizooma.com',
      // You can prefill subject/body later if desired
    );
    final ok = await launchUrl(uri);
    if (!ok) {
      _showSnack(context, 'Could not open email app.');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _EducationCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_EducationItem> items;

  const _EducationCategory({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: items,
      ),
    );
  }
}

class _EducationItem extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _EducationItem({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _ContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const _ContentScreen({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// Content data
final Map<String, String> personalInjuryBasics = {
  'title': 'What is Personal Injury Law?',
  'content': '''Personal injury law, also known as tort law, is designed to protect you if you or your property is injured or harmed due to someone else's act or failure to act. In a successful personal injury action, the person who caused the injury or harm compensates the person who suffered the losses.

The main goals of personal injury law are:

1. To make the injured person "whole" again by providing compensation for their losses
2. To deter others from committing the same harmful acts

Personal injury law covers a wide variety of situations including:
• Motor vehicle accidents
• Slip and fall accidents
• Medical malpractice
• Defective products
• Workplace injuries
• Assault and other intentional acts

In Washington State, personal injury cases are typically resolved through settlement negotiations or court trials. Most cases settle out of court, but having strong legal representation ensures you're prepared for either scenario.

Remember: Every case is unique, and the success of your claim depends on many factors including the strength of your evidence, the extent of your injuries, and the skill of your legal representation.''',
};

final Map<String, String> typesOfCases = {
  'title': 'Types of Personal Injury Cases',
  'content': '''Personal injury law encompasses many different types of accidents and injuries. Here are the most common types of cases:

MOTOR VEHICLE ACCIDENTS
• Car accidents
• Motorcycle accidents  
• Truck accidents
• Pedestrian accidents
• Bicycle accidents

PREMISES LIABILITY
• Slip and fall accidents
• Trip and fall accidents
• Inadequate security
• Swimming pool accidents
• Dog bites

MEDICAL MALPRACTICE
• Misdiagnosis or delayed diagnosis
• Surgical errors
• Medication errors
• Birth injuries
• Nursing home negligence

PRODUCT LIABILITY
• Defective automobiles
• Dangerous drugs
• Faulty medical devices
• Defective consumer products

WORKPLACE INJURIES
• Construction accidents
• Industrial accidents
• Repetitive stress injuries
• Toxic exposure

INTENTIONAL TORTS
• Assault and battery
• False imprisonment
• Intentional infliction of emotional distress

Each type of case has its own unique legal requirements and challenges. The key is proving that someone else's negligence or intentional act caused your injuries and that you suffered damages as a result.''',
};

final Map<String, String> statuteOfLimitations = {
  'title': 'Statute of Limitations in Washington',
  'content': '''The statute of limitations is a law that sets the maximum time after an event within which legal proceedings may be initiated. In Washington State, these time limits are strictly enforced, and missing a deadline can mean losing your right to compensation forever.

PERSONAL INJURY CASES: 3 Years
Most personal injury cases in Washington have a 3-year statute of limitations from the date of the injury.

MEDICAL MALPRACTICE: 3 Years (with exceptions)
Generally 3 years from the date of the malpractice, but no more than 8 years from the date of the act (with some exceptions for foreign objects or fraudulent concealment).

PRODUCT LIABILITY: 3 Years
3 years from the date of injury, but the product must be less than 12 years old (with some exceptions).

WRONGFUL DEATH: 3 Years
3 years from the date of death.

PROPERTY DAMAGE: 3 Years
3 years for damage to personal property.

IMPORTANT EXCEPTIONS:
• Discovery Rule: In some cases, the time limit begins when you discover (or should have discovered) the injury
• Minority: If the injured person is under 18, the statute may be extended
• Mental Incapacity: The time limit may be tolled for mental incapacity

Don't wait to seek legal advice. Evidence can be lost, witnesses' memories fade, and waiting too long can hurt your case even if you're within the statute of limitations.''',
};

final Map<String, String> yourRights = {
  'title': 'Your Rights After an Accident',
  'content': '''After an accident, you have important rights that protect your interests. Understanding these rights can help you avoid costly mistakes and ensure you receive fair compensation.

RIGHT TO MEDICAL TREATMENT
• You have the right to seek immediate medical attention
• You can choose your own doctor (in most cases)
• You're not required to use the insurance company's preferred providers
• You have the right to follow your doctor's treatment recommendations

RIGHT TO COMPENSATION
You may be entitled to compensation for:
• Medical expenses (past and future)
• Lost wages and earning capacity
• Pain and suffering
• Property damage
• Emotional distress
• Loss of consortium (for spouses)

RIGHT TO LEGAL REPRESENTATION
• You have the right to hire an attorney
• You can speak with an attorney before giving statements to insurance companies
• Your attorney can handle all communications with insurers
• Most personal injury attorneys work on contingency fees (no fee unless you win)

RIGHT TO REMAIN SILENT
• You don't have to give detailed statements to the other party's insurance company
• You should avoid admitting fault or speculating about what happened
• Stick to the basic facts when discussing the accident

RIGHT TO PRIVACY
• Your medical records are private and protected
• Insurance companies cannot access your medical records without authorization
• You control what information is released and to whom

RIGHT TO REFUSE SETTLEMENT
• You're not required to accept the first settlement offer
• You can negotiate for fair compensation
• You have the right to take your case to trial if necessary

Remember: Insurance companies are businesses focused on minimizing payouts. Having legal representation helps level the playing field.''',
};

final Map<String, String> insuranceDealing = {
  'title': 'Dealing with Insurance Companies',
  'content': '''Insurance companies will contact you after an accident, often within hours. While they may seem helpful, remember that their primary goal is to minimize their financial exposure. Here's what you need to know:

DO'S:
• Report the accident to your own insurance company promptly
• Provide basic facts about the accident (when, where, what happened)
• Be polite and cooperative
• Keep records of all communications
• Get names and contact information for all representatives
• Ask for written confirmation of any agreements
• Review your policy to understand your coverage

DON'TS:
• Don't admit fault or blame yourself
• Don't speculate about what happened
• Don't minimize your injuries or say you feel "fine"
• Don't give recorded statements without legal advice
• Don't sign anything without understanding it completely
• Don't accept the first settlement offer
• Don't provide access to medical records without legal counsel

COMMON INSURANCE TACTICS:
• Quick settlement offers (often much lower than fair value)
• Requesting unnecessary documentation
• Delaying tactics to pressure you into settling
• Disputing medical treatment or claiming it's unnecessary
• Arguing that you had pre-existing conditions
• Using your own statements against you

RECORDED STATEMENTS:
Be very careful about recorded statements. While you may be required to give a statement to your own insurance company, you're generally not required to give one to the other party's insurer. If you do give a statement:
• Keep it brief and factual
• Don't speculate or guess
• Say "I don't know" or "I don't remember" if you're unsure
• Don't volunteer information beyond what's asked

Remember: Having an attorney handle insurance communications can protect you from these tactics and ensure you receive fair treatment.''',
};

final Map<String, String> medicalRights = {
  'title': 'Medical Treatment Rights',
  'content': '''Your health is the top priority after an accident. Understanding your medical treatment rights helps ensure you get the care you need while protecting your legal case.

RIGHT TO CHOOSE YOUR DOCTOR
• You generally have the right to see the doctor of your choice
• You're not required to use the insurance company's preferred providers
• You can seek second opinions
• You can change doctors if you're not satisfied with your care

RIGHT TO NECESSARY TREATMENT
• You have the right to follow your doctor's treatment recommendations
• Insurance companies cannot dictate your medical treatment
• You can pursue treatment even if the insurance company disputes necessity
• You have the right to emergency medical care

DOCUMENTATION RIGHTS
• You have the right to copies of all your medical records
• You can control who has access to your medical information
• Medical records are confidential and protected by HIPAA
• You should keep copies of all medical bills and records

PAYMENT FOR MEDICAL TREATMENT
• Your health insurance may initially pay for treatment
• Auto insurance PIP (Personal Injury Protection) may cover medical bills
• The at-fault party's insurance should ultimately be responsible
• Some doctors will treat on a "lien" basis (payment from settlement)

IMPORTANT CONSIDERATIONS:
• Seek medical attention immediately, even if you feel fine
• Follow up with all recommended treatment
• Keep all medical appointments
• Don't delay treatment due to insurance concerns
• Document all symptoms and how they affect your daily life
• Be honest and thorough with your healthcare providers

PRE-EXISTING CONDITIONS
• You still have rights even if you had pre-existing conditions
• You can recover for aggravation of pre-existing conditions
• Be honest about your medical history with doctors and attorneys
• Don't let insurance companies use pre-existing conditions to deny your claim

INDEPENDENT MEDICAL EXAMINATIONS (IME)
• Insurance companies may request an IME
• You may be required to attend under your policy
• You have the right to have the exam recorded
• You can have your attorney present in some circumstances
• The IME doctor works for the insurance company, not you

Remember: Your health comes first. Get the treatment you need and worry about insurance issues later. An experienced attorney can help navigate medical payment issues while you focus on recovery.''',
};

final Map<String, String> legalProcess = {
  'title': 'How Personal Injury Cases Work',
  'content': '''Understanding the legal process can help reduce anxiety and set proper expectations for your case. Here's a step-by-step overview:

PHASE 1: INITIAL INVESTIGATION (1-3 months)
• Attorney reviews your case and determines viability
• Gather accident reports, medical records, and evidence
• Identify all potentially responsible parties
• Evaluate insurance coverage
• Begin medical treatment documentation

PHASE 2: MEDICAL TREATMENT (varies)
• Focus on recovery and following medical advice
• Document all treatment and how injuries affect your life
• Keep detailed records of expenses and lost wages
• Continue treatment until maximum medical improvement

PHASE 3: DEMAND AND NEGOTIATION (2-6 months)
• Prepare comprehensive demand package
• Submit demand to insurance companies
• Negotiate with insurance adjusters
• Most cases settle during this phase

PHASE 4: LITIGATION (if necessary)
• File lawsuit before statute of limitations expires
• Discovery phase: exchange of information and evidence
• Depositions: sworn testimony from parties and witnesses
• Expert witness preparation
• Mediation attempts

PHASE 5: TRIAL (if no settlement)
• Jury selection
• Opening statements
• Presentation of evidence
• Closing arguments
• Jury deliberation and verdict

PHASE 6: RESOLUTION
• Settlement agreement or court judgment
• Payment processing
• Case closure

FACTORS AFFECTING TIMELINE:
• Severity of injuries
• Complexity of liability issues
• Number of parties involved
• Insurance company cooperation
• Court schedules
• Settlement negotiations

TYPICAL TIMEFRAMES:
• Simple cases with clear liability: 6-18 months
• Complex cases: 2-4 years
• Cases going to trial: 3-5 years

Remember: Every case is unique, and your attorney will keep you informed throughout the process. The timeline can vary significantly based on the specific circumstances of your case.''',
};

final Map<String, String> settlementVsTrial = {
  'title': 'Settlement vs. Trial',
  'content': '''Most personal injury cases settle out of court, but it's important to understand both options and their implications.

SETTLEMENT

Advantages:
• Faster resolution (months vs. years)
• Lower legal costs
• Guaranteed outcome (no risk of losing at trial)
• Privacy (no public court records)
• Less stress and emotional toll
• Avoid uncertainty of jury verdict

Disadvantages:
• May be less than full trial value
• Final - can't change your mind later
• No public vindication or precedent

TRIAL

Advantages:
• Potential for larger awards
• Full public vindication
• Jury may award punitive damages
• Sets legal precedent
• Complete presentation of your story

Disadvantages:
• Uncertain outcome (could win big or lose everything)
• Longer timeline (years)
• Higher legal costs
• Emotional stress of trial
• Public proceedings
• Appeals process could extend timeline further

FACTORS TO CONSIDER:

Strength of Your Case:
• Clear liability favors settlement
• Disputed liability may require trial
• Strong evidence supports both options

Insurance Policy Limits:
• May cap potential recovery
• Could influence settlement vs. trial decision

Your Personal Situation:
• Need for quick resolution
• Ability to handle trial stress
• Financial pressures

THE DECISION PROCESS:
Your attorney will help you evaluate:
• Reasonable settlement range
• Likely trial outcome
• Risks and benefits of each option
• Your personal preferences and situation

Most attorneys will recommend accepting a fair settlement that adequately compensates you for your losses. However, if insurance companies refuse to offer reasonable compensation, trial may be necessary to achieve justice.

Remember: You always have the final say in whether to settle or go to trial. Your attorney's job is to advise you and advocate for your interests, but the decision is ultimately yours.''',
};

final Map<String, String> workingWithAttorney = {
  'title': 'Working with an Attorney',
  'content': '''Choosing the right attorney and building a strong working relationship is crucial to the success of your personal injury case.

CHOOSING AN ATTORNEY:

Experience:
• Look for attorneys who specialize in personal injury law
• Ask about their experience with cases similar to yours
• Inquire about their trial experience and success rate

Resources:
• Does the firm have resources to properly investigate your case?
• Do they work with medical experts and accident reconstructionists?
• Can they advance case expenses if needed?

Communication:
• Will the attorney personally handle your case?
• How often will you receive updates?
• Are they responsive to your calls and emails?

Fee Structure:
• Most personal injury attorneys work on contingency fees
• Understand what percentage they charge
• Ask about case expenses and who pays them
• Get fee agreements in writing

WHAT TO EXPECT:

Initial Consultation:
• Usually free for personal injury cases
• Bring all relevant documents
• Be honest about your case and medical history
• Ask questions about the process and timeline

Throughout Your Case:
• Regular updates on case progress
• Explanation of important developments
• Consultation before major decisions
• Preparation for depositions or trial testimony

YOUR RESPONSIBILITIES:

Communication:
• Keep your attorney informed of new medical treatment
• Report any communications from insurance companies
• Provide requested documents promptly
• Ask questions if you don't understand something

Medical Treatment:
• Follow your doctor's advice
• Keep all medical appointments
• Don't minimize symptoms to medical providers
• Report any new symptoms or problems

Documentation:
• Keep organized records of medical bills and expenses
• Save receipts for out-of-pocket costs
• Maintain a diary of how injuries affect your daily life
• Take photos of visible injuries or property damage

Social Media:
• Be careful about what you post online
• Assume insurance companies are monitoring your accounts
• Don't post photos or comments that contradict your injury claims

RED FLAGS:
• Attorney who guarantees specific results
• High-pressure tactics to sign immediately
• Lack of experience in personal injury law
• Poor communication or unresponsiveness
• Excessive fees or unusual fee arrangements

Remember: Your attorney works for you. You should feel comfortable asking questions, expressing concerns, and understanding what's happening with your case. A good attorney-client relationship is built on trust, communication, and mutual respect.''',
};

final Map<String, String> caseValue = {
  'title': 'How much is my case worth?',
  'content': '''This is one of the most common questions clients ask, and while every case is unique, understanding the factors that affect case value can help set realistic expectations.

TYPES OF DAMAGES:

Economic Damages (Quantifiable):
• Past medical expenses
• Future medical expenses  
• Lost wages
• Loss of earning capacity
• Property damage
• Out-of-pocket expenses

Non-Economic Damages (Subjective):
• Pain and suffering
• Emotional distress
• Loss of enjoyment of life
• Loss of consortium (for spouses)
• Disability and disfigurement

FACTORS AFFECTING VALUE:

Liability:
• How clear is fault?
• Was there comparative negligence?
• Are there multiple responsible parties?

Injury Severity:
• Permanent vs. temporary injuries
• Need for future medical treatment
• Impact on daily activities and work
• Disability rating

Medical Treatment:
• Consistency of treatment
• Following doctor's orders
• Gap in treatment (could hurt your case)
• Type of medical providers seen

Lost Income:
• Time missed from work
• Reduced earning capacity
• Career impact
• Benefits lost

Insurance Coverage:
• At-fault party's insurance limits
• Your own insurance coverage (UIM/PIP)
• Multiple insurance policies

Age and Occupation:
• Younger people may have higher future damages
• High-earning occupations increase lost wage claims
• Retirement age affects future loss calculations

CASE VALUE RANGES:
It's impossible to give specific ranges without knowing case details, but consider:

Minor Injuries (soft tissue): \$1,000 - \$25,000
Moderate Injuries (fractures, surgery): \$25,000 - \$100,000+
Severe Injuries (permanent disability): \$100,000 - \$1,000,000+
Catastrophic Injuries: \$1,000,000+

These are very rough guidelines. Actual values depend on all the factors mentioned above.

WHAT REDUCES VALUE:
• Pre-existing injuries or conditions
• Gaps in medical treatment
• Inconsistent complaints or symptoms
• Comparative negligence (you were partially at fault)
• Limited insurance coverage
• Lack of objective medical evidence

REALISTIC EXPECTATIONS:
• Insurance companies will start with low offers
• Settlement values are often less than trial potential
• Your attorney should provide a realistic range based on experience
• Case value may change as more information becomes available

Remember: While money can't undo your injuries, fair compensation should help you recover and move forward. Your attorney's job is to maximize your recovery while considering the risks and costs of pursuing your case.''',
};

final Map<String, String> caseTimeline = {
  'title': 'How long will my case take?',
  'content': '''Personal injury cases vary significantly in timeline depending on many factors. Understanding these factors can help you plan and set realistic expectations.

TYPICAL TIMELINES:

Simple Cases (Clear Liability, Minor Injuries):
• 6-18 months from accident to resolution
• Quick medical recovery
• Straightforward negotiations

Complex Cases (Disputed Liability, Serious Injuries):
• 2-4 years from accident to resolution
• Extended medical treatment
• Complicated negotiations or litigation

Trial Cases:
• 3-5+ years from accident to final resolution
• Include appeals if necessary
• Court schedules affect timing

PHASES AND TIMEFRAMES:

Medical Treatment (Variable):
• Can be days to years depending on injury severity
• Must reach "maximum medical improvement"
• Cannot settle until treatment is complete or prognosis is clear

Investigation and Preparation (2-6 months):
• Gathering evidence and records
• Identifying all responsible parties
• Evaluating insurance coverage
• Preparing demand package

Negotiation Phase (3-12 months):
• Initial demand submission
• Back-and-forth negotiations
• Multiple rounds of offers and counteroffers

Litigation Phase (if needed - 1-3 years):
• Filing lawsuit
• Discovery process
• Depositions and expert witnesses  
• Trial preparation and trial

FACTORS THAT SPEED UP CASES:
• Clear liability (obviously not your fault)
• Cooperative insurance companies
• Complete medical records
• Client follows medical advice
• Reasonable settlement offers

FACTORS THAT SLOW DOWN CASES:
• Disputed liability or comparative negligence
• Severe or complex injuries
• Multiple parties involved
• Uncooperative insurance companies
• Need for expert witnesses
• Court backlogs
• Appeals

MEDICAL TREATMENT CONSIDERATIONS:
• Don't rush to settle before understanding full extent of injuries
• Some injuries take months or years to fully manifest
• Future medical needs must be considered
• Premature settlement can't be undone

WHY CASES TAKE TIME:
• Insurance companies benefit from delays
• Thorough investigation takes time
• Medical treatment can't be rushed
• Strong cases require proper development
• Court processes have built-in delays

WHAT YOU CAN DO:
• Follow all medical advice
• Keep detailed records
• Respond promptly to attorney requests
• Be patient with the process
• Stay in regular communication with your attorney

RED FLAGS:
• Attorney who rushes you to settle
• Promises of quick resolution
• Not waiting for medical improvement
• Pressure to accept inadequate offers

Remember: While it's natural to want your case resolved quickly, taking the time to properly develop your case usually results in better outcomes. Your attorney will balance the need for thorough preparation with your desire for resolution.''',
};

final Map<String, String> partialFault = {
  'title': 'What if I was partially at fault?',
  'content': '''Being partially at fault doesn't necessarily bar you from recovery in Washington State. Understanding comparative negligence law can help you understand your rights.

WASHINGTON'S COMPARATIVE NEGLIGENCE LAW:

Pure Comparative Negligence:
• You can recover damages even if you were mostly at fault
• Your recovery is reduced by your percentage of fault
• Example: \$100,000 damages, 30% your fault = \$70,000 recovery

No Threshold:
• Unlike some states, Washington has no threshold
• You can recover even if you were 99% at fault
• Your recovery is simply reduced by your fault percentage

HOW FAULT IS DETERMINED:

By Insurance Companies:
• Initial fault assessments during claims process
• May be biased toward their insured
• Can be disputed and negotiated

By Jury (if trial):
• Jury assigns fault percentages to all parties
• Based on evidence presented at trial
• Final determination of fault allocation

COMMON PARTIAL FAULT SCENARIOS:

Car Accidents:
• Speeding but other driver ran red light
• Following too closely but lead car brake-checked
• Changing lanes but other driver was in blind spot

Slip and Fall:
• Not watching where you were going
• Ignoring warning signs
• Being in restricted areas

FACTORS AFFECTING FAULT:

Your Actions:
• Traffic violations
• Not following safety rules
• Distracted driving or walking
• Intoxication

Comparative Actions:
• What did the other party do wrong?
• Who had the last clear chance to avoid accident?
• Severity of each party's negligence

IMPACT ON YOUR CASE:

Settlement Negotiations:
• Insurance companies will argue for higher fault percentage
• Your attorney will argue for lower percentage
• Compromise often reached

Trial Considerations:
• Jury instruction on comparative negligence
• Evidence presented about all parties' actions
• Risk of jury assigning high fault percentage

WHAT NOT TO SAY:
• "It was my fault"
• "I'm sorry" (can be interpreted as admission)
• "I should have been more careful"
• "I wasn't paying attention"

WHAT TO DO:
• Let your attorney handle fault discussions
• Provide honest account of events to your attorney
• Don't admit fault to insurance companies
• Focus on the other party's negligent actions

EXAMPLES:

Scenario 1: Rear-end collision while you were speeding
• Other driver still primarily at fault for not maintaining safe distance
• Your speeding might be 20% of fault
• You could still recover 80% of damages

Scenario 2: Slip and fall while texting
• Property owner still responsible for dangerous condition
• Your distraction might be 40% of fault  
• You could still recover 60% of damages

Remember: Even if you made a mistake, the other party may still bear primary responsibility. Don't assume you have no case just because you weren't perfect. Speak with an experienced attorney who can evaluate the full circumstances and protect your rights.''',
};