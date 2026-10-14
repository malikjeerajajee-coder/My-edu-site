export interface Class11Board {
  slug: string;
  name: string;
  shortName: string;
  officialDomain: string;
  smsCode: string;
  districts: string;
  established: string;
  hq: string;
}

export const CLASS11_BOARDS: Class11Board[] = [
  { slug: 'lahore',      name: 'BISE Lahore',      shortName: 'Lahore',      officialDomain: 'biselahore.com',       smsCode: '800291', districts: 'Lahore, Kasur, Sheikhupura, Nankana Sahib',            established: '1954', hq: 'Lahore' },
  { slug: 'gujranwala',  name: 'BISE Gujranwala',  shortName: 'Gujranwala',  officialDomain: 'bisegrw.edu.pk',       smsCode: '800299', districts: 'Gujranwala, Sialkot, Gujrat, Hafizabad, Narowal, Mandi Bahauddin', established: '1976', hq: 'Gujranwala' },
  { slug: 'faisalabad',  name: 'BISE Faisalabad',  shortName: 'Faisalabad',  officialDomain: 'bisefsd.edu.pk',       smsCode: '800240', districts: 'Faisalabad, Jhang, Toba Tek Singh, Chiniot',            established: '1976', hq: 'Faisalabad' },
  { slug: 'multan',      name: 'BISE Multan',      shortName: 'Multan',      officialDomain: 'bisemultan.edu.pk',    smsCode: '800293', districts: 'Multan, Vehari, Khanewal, Lodhran',                     established: '1968', hq: 'Multan' },
  { slug: 'rawalpindi',  name: 'BISE Rawalpindi',  shortName: 'Rawalpindi',  officialDomain: 'biserawalpindi.edu.pk', smsCode: '800296', districts: 'Rawalpindi, Attock, Chakwal, Jhelum',                   established: '1977', hq: 'Rawalpindi' },
  { slug: 'sargodha',    name: 'BISE Sargodha',    shortName: 'Sargodha',    officialDomain: 'bisesargodha.edu.pk',  smsCode: '800290', districts: 'Sargodha, Mianwali, Khushab, Bhakkar',                  established: '1968', hq: 'Sargodha' },
  { slug: 'bahawalpur',  name: 'BISE Bahawalpur',  shortName: 'Bahawalpur',  officialDomain: 'bisebwp.edu.pk',       smsCode: '800298', districts: 'Bahawalpur, Bahawalnagar, Rahim Yar Khan',              established: '1978', hq: 'Bahawalpur' },
  { slug: 'dg-khan',     name: 'BISE DG Khan',     shortName: 'DG Khan',     officialDomain: 'bisedgkhan.edu.pk',    smsCode: '800295', districts: 'Dera Ghazi Khan, Layyah, Muzaffargarh, Rajanpur',        established: '1989', hq: 'Dera Ghazi Khan' },
  { slug: 'sahiwal',     name: 'BISE Sahiwal',     shortName: 'Sahiwal',     officialDomain: 'bisesahiwal.edu.pk',   smsCode: '800292', districts: 'Sahiwal, Okara, Pakpattan',                              established: '2012', hq: 'Sahiwal' },
];

export const RESULT_YEAR = '2026';
export const RESULT_DATE = 'October 22, 2026';
export const RESULT_TIME = '10:00 AM (PKT)';
export const TOTAL_MARKS = 550;
export const PASSING_PERCENT = 40;
export const PASSING_MARKS = 220;
export const GRADING_SCALE = [
  { grade: 'A+', marks: '80% and above', range: '440–550' },
  { grade: 'A',  marks: '70%–79%',       range: '385–439' },
  { grade: 'B',  marks: '60%–69%',       range: '330–384' },
  { grade: 'C',  marks: '50%–59%',       range: '275–329' },
  { grade: 'D',  marks: '40%–49%',       range: '220–274' },
  { grade: 'U',  marks: 'Below 40%',     range: 'Unsatisfactory' },
];
