import os
import glob

# Search for the main index file (Astro source or static HTML)
files = glob.glob('src/pages/index.astro') + \
        glob.glob('src/pages/index.html') + \
        glob.glob('index.html') + \
        glob.glob('public/index.html') + \
        glob.glob('dist/index.html')

# Prefer source files over dist
source_files = [f for f in files if 'dist' not in f]
filepath = source_files[0] if source_files else (files[0] if files else None)

if not filepath:
    print("❌ Could not find index.astro or index.html. Ensure you are in the project root.")
    exit(1)

print(f"📝 Updating {filepath}...")

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

original_content = content

# 1. Popular Pills after search form
pills = '''
    <div class="mt-6 flex flex-wrap gap-2">
      <span class="text-xs font-semibold text-neutral-500 uppercase tracking-wide py-1.5 mr-2">Popular:</span>
      <a href="/My-edu-site/notes" class="px-3 py-1.5 text-sm font-medium bg-blue-50 text-[#0620ed] rounded-full hover:bg-blue-100 transition-colors border border-blue-100">Matric Notes</a>
      <a href="/My-edu-site/past-papers" class="px-3 py-1.5 text-sm font-medium bg-green-50 text-green-700 rounded-full hover:bg-green-100 transition-colors border border-green-100">FSc Past Papers</a>
      <a href="/My-edu-site/guess-papers" class="px-3 py-1.5 text-sm font-medium bg-orange-50 text-orange-700 rounded-full hover:bg-orange-100 transition-colors border border-orange-100">9th Guess Papers</a>
      <a href="/My-edu-site/books" class="px-3 py-1.5 text-sm font-medium bg-purple-50 text-purple-700 rounded-full hover:bg-purple-100 transition-colors border border-purple-100">PTB Textbooks</a>
    </div>
'''
if '</form>' in content and 'Popular:' not in content:
    content = content.replace('</form>', f'</form>{pills}', 1)

# 2. How It Works section before "Choose your board"
how_it_works = '''
<section class="bg-neutral-50 border-y border-neutral-200 py-16 sm:py-24">
  <div class="mx-auto max-w-[1320px] px-4 sm:px-6 lg:px-10">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-extrabold tracking-tight text-neutral-900">Why top students choose TaleemHub</h2>
      <p class="mt-3 text-lg text-neutral-600">Tailored specifically for the Pakistani board syllabus.</p>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div class="bg-white rounded-2xl p-8 shadow-sm border border-neutral-200 hover:shadow-md transition-shadow">
        <div class="w-12 h-12 rounded-xl bg-[#0620ed]/10 flex items-center justify-center text-[#0620ed] font-bold text-xl mb-4">1</div>
        <h3 class="text-xl font-bold text-neutral-900 mb-2">Select Your Board</h3>
        <p class="text-neutral-600 text-sm leading-relaxed">Resources perfectly aligned with Punjab, Federal, Sindh, KPK, and AJK syllabi. No more wasting time on irrelevant material.</p>
      </div>
      <div class="bg-white rounded-2xl p-8 shadow-sm border border-neutral-200 hover:shadow-md transition-shadow">
        <div class="w-12 h-12 rounded-xl bg-[#0620ed]/10 flex items-center justify-center text-[#0620ed] font-bold text-xl mb-4">2</div>
        <h3 class="text-xl font-bold text-neutral-900 mb-2">Download & Revise</h3>
        <p class="text-neutral-600 text-sm leading-relaxed">Access chapter-wise notes, solved past papers, and exact pairing schemes on any device, offline or online.</p>
      </div>
      <div class="bg-white rounded-2xl p-8 shadow-sm border border-neutral-200 hover:shadow-md transition-shadow">
        <div class="w-12 h-12 rounded-xl bg-[#0620ed]/10 flex items-center justify-center text-[#0620ed] font-bold text-xl mb-4">3</div>
        <h3 class="text-xl font-bold text-neutral-900 mb-2">Ace Your Exams</h3>
        <p class="text-neutral-600 text-sm leading-relaxed">Practice with our exclusive guess papers and MCQs to walk into your exam hall with 100% confidence.</p>
      </div>
    </div>
  </div>
</section>
'''
if 'Why top students choose TaleemHub' not in content and 'Choose your board' in content:
    content = content.replace('<section class="mx-auto max-w-[1320px] px-4 py-14 sm:px-6 lg:px-10 lg:py-20">', f'{how_it_works}\n<section class="mx-auto max-w-[1320px] px-4 py-14 sm:px-6 lg:px-10 lg:py-20">', 1)

# 3. Curators & Testimonials before Footer
curators_testimonials = '''
<section class="mx-auto max-w-[1320px] px-4 sm:px-6 lg:px-10 py-16 sm:py-24">
  <div class="text-center mb-12">
    <h2 class="text-3xl font-extrabold tracking-tight text-neutral-900">Curated by Pakistan's Top Educators</h2>
    <p class="mt-3 text-lg text-neutral-600">We work harder so you can study smarter.</p>
  </div>
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-6">
    <div class="flex flex-col items-center p-6 rounded-2xl border border-neutral-200 bg-white hover:shadow-lg transition-shadow text-center">
      <div class="w-20 h-20 rounded-full bg-gradient-to-br from-blue-400 to-indigo-600 flex items-center justify-center text-white text-2xl font-bold mb-4">AK</div>
      <h3 class="font-bold text-neutral-900">Asif Khan</h3>
      <p class="text-sm text-neutral-500">Maths Specialist<br>Punjab Board</p>
    </div>
    <div class="flex flex-col items-center p-6 rounded-2xl border border-neutral-200 bg-white hover:shadow-lg transition-shadow text-center">
      <div class="w-20 h-20 rounded-full bg-gradient-to-br from-green-400 to-emerald-600 flex items-center justify-center text-white text-2xl font-bold mb-4">SF</div>
      <h3 class="font-bold text-neutral-900">Sana Fatima</h3>
      <p class="text-sm text-neutral-500">Biology Expert<br>Federal Board</p>
    </div>
    <div class="flex flex-col items-center p-6 rounded-2xl border border-neutral-200 bg-white hover:shadow-lg transition-shadow text-center">
      <div class="w-20 h-20 rounded-full bg-gradient-to-br from-orange-400 to-red-600 flex items-center justify-center text-white text-2xl font-bold mb-4">UA</div>
      <h3 class="font-bold text-neutral-900">Usman Ali</h3>
      <p class="text-sm text-neutral-500">Physics Lead<br>Sindh Board</p>
    </div>
    <div class="flex flex-col items-center p-6 rounded-2xl border border-neutral-200 bg-white hover:shadow-lg transition-shadow text-center">
      <div class="w-20 h-20 rounded-full bg-gradient-to-br from-purple-400 to-fuchsia-600 flex items-center justify-center text-white text-2xl font-bold mb-4">MH</div>
      <h3 class="font-bold text-neutral-900">Malik Hamza</h3>
      <p class="text-sm text-neutral-500">Chemistry Pro<br>KPK Board</p>
    </div>
  </div>
</section>

<section class="bg-[#0620ed] py-16 sm:py-24 text-white">
  <div class="mx-auto max-w-[1320px] px-4 sm:px-6 lg:px-10">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-extrabold tracking-tight">Real Results from Real Students</h2>
      <div class="flex items-center justify-center gap-2 mt-4">
        <span class="text-yellow-400 text-xl">★★★★★</span>
        <span class="font-semibold">Rated 4.9/5 by Students</span>
      </div>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div class="bg-white/10 backdrop-blur-sm p-8 rounded-2xl border border-white/20">
        <p class="text-lg italic leading-relaxed mb-6">"I scored 1040/1100 in my Matric exams. TaleemHub's guess papers were exactly what appeared in the exam!"</p>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center font-bold">H</div>
          <div>
            <div class="font-bold">Hassan Raza</div>
            <div class="text-sm opacity-80">Federal Board, Class 10</div>
          </div>
        </div>
      </div>
      <div class="bg-white/10 backdrop-blur-sm p-8 rounded-2xl border border-white/20">
        <p class="text-lg italic leading-relaxed mb-6">"The pairing schemes saved me so much time. I knew exactly which chapters to focus on for my FSc part 1."</p>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center font-bold">A</div>
          <div>
            <div class="font-bold">Ayesha Siddiqui</div>
            <div class="text-sm opacity-80">Punjab Board, Class 11</div>
          </div>
        </div>
      </div>
      <div class="bg-white/10 backdrop-blur-sm p-8 rounded-2xl border border-white/20">
        <p class="text-lg italic leading-relaxed mb-6">"Finally, notes that match our syllabus perfectly without the crazy subscription fees of other sites."</p>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center font-bold">U</div>
          <div>
            <div class="font-bold">Usman Tariq</div>
            <div class="text-sm opacity-80">Sindh Board, Class 12</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
'''

if 'Real Results from Real Students' not in content:
    if '</main>' in content:
        content = content.replace('</main>', f'{curators_testimonials}\n</main>')
    elif '<footer' in content:
        content = content.replace('<footer', f'{curators_testimonials}\n<footer', 1)
    elif '</body>' in content:
        content = content.replace('</body>', f'{curators_testimonials}\n</body>')

# Write back
if content != original_content:
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Successfully upgraded {filepath}!")
else:
    print("⚠️ No changes were made. The design components might already be installed.")
