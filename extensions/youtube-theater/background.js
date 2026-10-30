/*
 * YouTube records the theater/default layout solely in the `wide` cookie,
 * which it writes without an expiry. Chromium keeps session cookies in memory
 * only, so the preference dies with the browser process. Re-arm the expiry
 * each time YouTube writes it, keeping whatever value the user chose.
 */

const DOMAIN = '.youtube.com';
const MAX_AGE_S = 31536000;
const NAME = 'wide';
const SITE = 'https://www.youtube.com/';
const THEATER = '1';

const persist = async value => {
    const cookie = await chrome.cookies.set({
        url: SITE,
        domain: DOMAIN,
        path: '/',
        name: NAME,
        value,
        expirationDate: Date.now() / 1000 + MAX_AGE_S,
    });
    if ( cookie === null ) {
        console.warn('youtube-theater: cannot write cookie', NAME, value);
    }
};

const onChanged = ({ cookie, removed }) => {
    if ( cookie.name !== NAME ) { return; }
    if ( removed ) { return; }
    if ( cookie.session === false ) { return; }
    persist(cookie.value);
};

const seed = async ( ) => {
    const cookie = await chrome.cookies.get({ url: SITE, name: NAME });
    if ( cookie !== null ) { return; }
    await persist(THEATER);
};

chrome.cookies.onChanged.addListener(onChanged);
chrome.runtime.onStartup.addListener(seed);
chrome.runtime.onInstalled.addListener(seed);
