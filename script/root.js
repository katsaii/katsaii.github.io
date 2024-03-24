fetch("/README.txt")
		.then(data => data.text())
		.then(text => {
			console.log(text);
		});

const sound_src = "/audio/arp.wav";
const sounds = [];
const sound_count = 10;
for (let i = 0; i < sound_count; i += 1) {
	const sound = new Audio(sound_src);
	sound.volume = 0.1;
	sounds.push(sound);
}
let sound_index = 0;

/// Plays the next sound in the list.
function play_sound(rate) {
	sound_index = (sound_index + 1) % sound_count;
	let sound = sounds[sound_index];
	sound.pause();
	sound.currentTime = 0;
	sound.playbackRate = rate;
	sound.play();
}

/// Appends some content to an attribute. Creates the attribute if it doesn't exist.
function append_attribute(elem, name, value) {
	let content = elem.getAttribute(name);
	if (content != null) {
		value = content + value;
	}
	elem.setAttribute(name, value);
}

let elems = document.getElementsByClassName("anim-squish");
for (elem of elems) {
	append_attribute(elem, "onmousedown", ";play_sound(0.6)");
	append_attribute(elem, "onmouseup", ";play_sound(1.1)");
}

/// Toggles the current theme without affecting local storage.
function toggle_theme() {
	let root = document.documentElement;
	root.classList.toggle("dark-mode");
	return root.classList.contains("dark-mode");
}

/// Enables or disables dark mode.
function enable_darkmode() {
	let enabled = toggle_theme();
	window.localStorage.setItem("dark-mode", enabled);
}

let darkmode = window.localStorage.getItem("dark-mode");
if (darkmode == null) {
	if (window.matchMedia &&
			window.matchMedia("(prefers-color-scheme: dark)").matches) {
		// thanks @Sidorakh
		toggle_theme();
	}
} else if (darkmode == "true") {
	toggle_theme();
}
