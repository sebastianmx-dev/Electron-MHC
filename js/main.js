const { app, BrowserWindow } = require('electron')
const path = require('path')

const debug = require('electron-debug');
debug();

function createWindow () {
  const win = new BrowserWindow({
    label: 'Micro Health Check',
    width: 800,
    height: 600,
    icon: path.join(__dirname , '../icon/icon.ico'),

    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      preload: path.join(__dirname, 'preload.js')
    }
  })

  //win.loadFile('dashboard.html')
  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

