# Usage
```
python scrape2.py
python classify.py
python export_csv.py
RScript analysis.R
```

-----------------------------------

# Pre-Setup
```
brew install mongodb pyenv pyenv-virtualenvwrapper
ln -s /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
pyenv install 2.7.8
pyenv global 2.7.8
```

## Add this to your rc file
```
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
pyenv virtualenvwrapper
```

# Setup
```
mkvirtualenv nusaferide
pip install -r requirements.txt
```