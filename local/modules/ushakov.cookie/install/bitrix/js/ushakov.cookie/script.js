(function () {
  if (document.cookie.split('; ').find(row => row.startsWith('ushakov_cookie='))) {
    return
  }

  fetch('/bitrix/tools/ushakov_cookie_options.php', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    credentials: 'same-origin',
    body: new URLSearchParams({
      'SITE_ID': BX.message('SITE_ID'),
    }),
  })
  .then(response => response.json())
  .then(options => {
    handleContentLoaded(options)
  })
  .catch(error => {
    console.error('Ошибка при запросе опций модуля ushakov.cookie', error)
  })


  function handleContentLoaded (response) {
    const cfg = response && response.data ? response.data : {};
    const delay = parseInt(cfg.delayMs, 10);
    const run = () => {
      if (!isNaN(delay) && delay > 0) {
        setTimeout(() => insertCookieDiv(cfg), delay);
      } else {
        insertCookieDiv(cfg);
      }
    };

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', run);
    } else {
      run();
    }
  }

  function insertCookieDiv(options) {
    // Создаем элементы
    let cookieDiv = document.createElement('div')
    cookieDiv.style.zIndex = options.zIndex
    cookieDiv.id = 'ushakov-cookie-wrap'
    cookieDiv.className = 'ushakov-cookie'
    if (options.disableMob === 'Y') {
      cookieDiv.classList.add('ushakov-cookie--d-mob-none')
    }

    // позиция + вертикальный отступ для контейнера
    if (options.position === 'top') {
      cookieDiv.classList.add('ushakov-cookie--pos-top')
      cookieDiv.style.top = options.offsetY || '0'
      cookieDiv.style.bottom = 'auto'          // важно
    } else {
      cookieDiv.classList.add('ushakov-cookie--pos-bottom')
      cookieDiv.style.bottom = options.offsetY || '0'
      cookieDiv.style.top = 'auto'             // важно
    }

    let innerDiv = document.createElement('div')
    innerDiv.classList.add('ushakov-cookie-bg-custom');
    innerDiv.style.setProperty('--ushakov-cookie-bg', options.bgColor);

    innerDiv.style.setProperty('--ushakov-cookie-text-color', options.textColor);

    innerDiv.style.setProperty('--ushakov-cookie-font-size', options.fontSize);

    // радиус
    if (options.borderRadius) {
      innerDiv.style.setProperty('--ushakov-cookie-radius', options.borderRadius);
    }

    // тень (вкл/выкл)
    if (options.shadow === 'Y') {
      innerDiv.style.setProperty('--ushakov-cookie-shadow', '0 8px 24px rgba(0, 0, 0, 0.85)');
    } else {
      innerDiv.style.setProperty('--ushakov-cookie-shadow', 'none');
    }

    // выравнивание
    const align = options.align || 'center';
    cookieDiv.classList.add('ushakov-cookie--align-' + align);

    // макс. ширина и горизонтальные отступы
    innerDiv.style.setProperty('--ushakov-cookie-max-width', options.maxWidth)
    innerDiv.style.setProperty('--ushakov-cookie-offset-x', options.offsetX)

    let cookieText = document.createElement('div')
    cookieText.className = 'ushakov-cookie__text'

    cookieText.innerHTML = options.text

    // блок с кнопками
    const actionsWrapper = document.createElement('div')
    actionsWrapper.className = 'ushakov-cookie__actions'

    const acceptButton = document.createElement('button')
    acceptButton.type = 'button'
    acceptButton.className = 'ushakov-cookie__accept'
    acceptButton.textContent = (options.textButton && options.textButton.trim() !== '') ? options.textButton : 'Принять'
    acceptButton.setAttribute('aria-label', 'Принять cookies')
    acceptButton.onclick = sendCookieRequestAndRemoveElement

    const closeIcon = document.createElement('button')
    closeIcon.type = 'button'
    closeIcon.className = 'ushakov-cookie__close'
    closeIcon.setAttribute('aria-label', 'Закрыть уведомление')
    const closeImg = document.createElement('img')
    closeImg.src = '/bitrix/images/ushakov.cookie/close.svg'
    closeImg.alt = ''
    closeImg.setAttribute('aria-hidden', 'true')
    closeIcon.appendChild(closeImg)
    closeIcon.onclick = hideCookieBanner

    actionsWrapper.appendChild(acceptButton)
    actionsWrapper.appendChild(closeIcon)

    // Собираем и вставляем в документ
    innerDiv.appendChild(cookieText)
    innerDiv.appendChild(actionsWrapper)
    cookieDiv.appendChild(innerDiv)
    document.body.appendChild(cookieDiv)
  }

  function sendCookieRequestAndRemoveElement () {
    fetch('/bitrix/tools/ushakov_cookie_save.php', {
      method: 'GET', // в оригинале BX.ajax делал GET-запрос, поэтому явно укажем
      credentials: 'same-origin' // аналог BX.ajax: куки и сессия будут отправлены
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok')
      }
      return response.text() // или .json(), если на сервере JSON
    })
    .then(data => {
      console.log('Cookie saved successfully')
      // Если нужно что-то сделать с ответом сервера, делаем это здесь
    })
    .catch(error => {
      console.error('Error saving cookie:', error)
    })
    .finally(() => {
      const element = document.getElementById('ushakov-cookie-wrap')
      if (element) {
        element.remove()
      }
    })
  }

  function hideCookieBanner () {
    const element = document.getElementById('ushakov-cookie-wrap')
    if (element) {
      element.remove()
    }
  }
})();
