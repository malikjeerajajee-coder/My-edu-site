export interface Class11Board {
  slug: string;
  name: string;
  shortName: string;
  officialDomain: string;
  smsCode: string;
  districts: string;
  established: string;
  hq: string;
  gazetteUrl: string;
  totalPages: string;
  fileSize: string;
  passPercentage: string;
  candidates: string;
}

export const CLASS11_BOARDS: Class11Board[] = [
  { 
    slug: 'lahore', name: 'BISE Lahore', shortName: 'Lahore', officialDomain: 'biselahore.com', smsCode: '800291', 
    districts: 'Lahore, Kasur, Sheikhupura, Nankana Sahib', established: '1954', hq: 'Lahore', 
    gazetteUrl: 'https://drive.google.com/file/d/1DT8_VJ7UeenIxTpD3X5CEcvHNG76brYo/view',
    totalPages: '1,031', fileSize: '~8 MB', passPercentage: '60.03%', candidates: '168,000+'
  },
  { 
    slug: 'gujranwala', name: 'BISE Gujranwala', shortName: 'Gujranwala', officialDomain: 'bisegrw.edu.pk', smsCode: '800299', 
    districts: 'Gujranwala, Sialkot, Gujrat, Hafizabad, Narowal, Mandi Bahauddin', established: '1976', hq: 'Gujranwala', 
    gazetteUrl: 'https://drive.google.com/file/d/1nQCo5egl53pfefNEdgWgV1ep4v6UJWR9/view',
    totalPages: '1,921', fileSize: '~14 MB', passPercentage: '58.16%', candidates: '135,983'
  },
  { 
    slug: 'faisalabad', name: 'BISE Faisalabad', shortName: 'Faisalabad', officialDomain: 'bisefsd.edu.pk', smsCode: '800240', 
    districts: 'Faisalabad, Jhang, Toba Tek Singh, Chiniot', established: '1976', hq: 'Faisalabad', 
    gazetteUrl: 'https://drive.google.com/file/d/1O21nwq3JaalBfND8RWcuxIU3WevBd1Cu/view',
    totalPages: '2,300+', fileSize: '~12 MB', passPercentage: '61.67%', candidates: '105,663'
  },
  { 
    slug: 'multan', name: 'BISE Multan', shortName: 'Multan', officialDomain: 'bisemultan.edu.pk', smsCode: '800293', 
    districts: 'Multan, Vehari, Khanewal, Lodhran', established: '1968', hq: 'Multan', 
    gazetteUrl: 'https://drive.google.com/file/d/1orbgKCv10IafOnXunL-F13f2xGHIjtFU/view',
    totalPages: '568', fileSize: '~5 MB', passPercentage: '63.10%', candidates: '80,000+'
  },
  { 
    slug: 'rawalpindi', name: 'BISE Rawalpindi', shortName: 'Rawalpindi', officialDomain: 'biserawalpindi.edu.pk', smsCode: '800296', 
    districts: 'Rawalpindi, Attock, Chakwal, Jhelum', established: '1977', hq: 'Rawalpindi', 
    gazetteUrl: 'https://drive.google.com/file/d/15HSvzV9U5joy1MhDy8uZalrz9YBQdWPx/view',
    totalPages: '850+', fileSize: '~7 MB', passPercentage: '54.23%', candidates: '55,834'
  },
  { 
    slug: 'sargodha', name: 'BISE Sargodha', shortName: 'Sargodha', officialDomain: 'bisesargodha.edu.pk', smsCode: '800290', 
    districts: 'Sargodha, Mianwali, Khushab, Bhakkar', established: '1968', hq: 'Sargodha', 
    gazetteUrl: 'https://drive.google.com/file/d/13J5_KzuPMP0AYm1WolChBpSezMlW6pd8/view',
    totalPages: '671', fileSize: '~6 MB', passPercentage: '66.79%', candidates: '90,000+'
  },
  { 
    slug: 'bahawalpur', name: 'BISE Bahawalpur', shortName: 'Bahawalpur', officialDomain: 'bisebwp.edu.pk', smsCode: '800298', 
    districts: 'Bahawalpur, Bahawalnagar, Rahim Yar Khan', established: '1978', hq: 'Bahawalpur', 
    gazetteUrl: 'https://drive.google.com/file/d/1khsNbiGTUfYM9CimoORJRrx_uNB1lVpz/view',
    totalPages: '900+', fileSize: '~8 MB', passPercentage: '59.50%', candidates: '85,000+'
  },
  { 
    slug: 'dg-khan', name: 'BISE DG Khan', shortName: 'DG Khan', officialDomain: 'bisedgkhan.edu.pk', smsCode: '800295', 
    districts: 'Dera Ghazi Khan, Layyah, Muzaffargarh, Rajanpur', established: '1989', hq: 'Dera Ghazi Khan', 
    gazetteUrl: 'https://drive.google.com/file/d/11GGroJqsnxaONiilVxmGUssTgstwQaXt/view',
    totalPages: '1,518', fileSize: '~10 MB', passPercentage: '62.40%', candidates: '70,000+'
  },
  { 
    slug: 'sahiwal', name: 'BISE Sahiwal', shortName: 'Sahiwal', officialDomain: 'bisesahiwal.edu.pk', smsCode: '800292', 
    districts: 'Sahiwal, Okara, Pakpattan', established: '2012', hq: 'Sahiwal', 
    gazetteUrl: 'https://drive.google.com/file/d/13z3gdI-2ELvmIfMUACknB45MfDtjYf18/view',
    totalPages: '600+', fileSize: '~6 MB', passPercentage: '65.20%', candidates: '65,000+'
  },
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
