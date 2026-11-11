#pragma once

#include <QFileSystemWatcher>
#include <QObject>
#include <QTimer>

// One hyprk state file ($HYPRK_STATE/<name>.json, e.g. appearance.json), watched with inotify like Settings'
// QsWatch (Quickshell FileView): `text` follows every write, including atomic replaces (temp + rename), so the
// Finder follows the system appearance live. "" while the file is missing. No polling.
class StateFile : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
public:
    explicit StateFile(QObject *parent = nullptr);
    QString path() const { return m_path; }
    void setPath(const QString &path);
    QString text() const { return m_text; }

signals:
    void pathChanged();
    void textChanged();

private:
    void rewatch();
    void reload();
    QString m_path;
    QString m_text;
    QFileSystemWatcher m_watcher;
    QTimer m_settle;   // one read per burst of events (write + rename arrive together)
};
