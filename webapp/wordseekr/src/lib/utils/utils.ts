import { Capacitor } from '@capacitor/core';

export function getIsSmallScreen() {
	// const smallWidth = 1134;
	const isSmallScreen = Capacitor.isNativePlatform(); // && window.innerWidth < smallWidth;
	return isSmallScreen;
}

export const adsIconBase64 =
	'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAABSElEQVR4nO3ZP0oDQRiG8UGwsFKwsLD2AF7AC5hoZesVvIIgAVtLW0tvoOCfTg9gr2BjYaNJYSH+ZEgCi42bqNmZdZ5+v92H9/t2Z3ZCKBQKU4FtXGOgeQa4QndSiUPp0pskidTp1BGJ7ZQ6l3VE+tLntY5IFoQikhihJPKPEuniXu4iYXjtAvbx9ruPPWORSo01nE1bKxmRSq3Ybo/T1kxGZFRvEUd4z1pkDNZxk71IBHPYxXPWImOwjGN8ZC0yBhu4y14kgnnsTbp9CKmJVO67ipO2iJxmK9KK1pL7sGNlNA95vn614YNouES5/alAYyJYyn7RiB08/aZAExur82lrNS7Siq0utvBgRoQ/FJkpoYgkRiiJZJhIX/q81BGJp6epc1FHJP4dTJ3Nb0VGMj3pclBLoiLTiaenicxMP7ZT7SQKhUL4yieOYHQusx8oEQAAAABJRU5ErkJggg==';
