#pragma once

#include <QClipboard>
#include <QGuiApplication>
#include <QMimeData>
#include <QObject>
#include <QUrl>

// Finder's Copy / Paste Item: file URLs on the system clipboard (text/uri-list, plus GNOME's copied-files list so
// GTK file managers paste them too). `files` is the local paths on the clipboard now.
class Clipboard : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList files READ files NOTIFY changed)
public:
    explicit Clipboard(QObject *parent = nullptr) : QObject(parent)
    {
        connect(QGuiApplication::clipboard(), &QClipboard::dataChanged, this, &Clipboard::changed);
    }
    QStringList files() const
    {
        QStringList out;
        if (const QMimeData *m = QGuiApplication::clipboard()->mimeData(); m && m->hasUrls())
            for (const QUrl &u : m->urls())
                if (u.isLocalFile())
                    out << u.toLocalFile();
        return out;
    }
    Q_INVOKABLE void copyFiles(const QStringList &paths)
    {
        auto *m = new QMimeData;
        QList<QUrl> urls;
        QByteArray gnome("copy");
        for (const QString &p : paths) {
            urls << QUrl::fromLocalFile(p);
            gnome += '\n' + QUrl::fromLocalFile(p).toEncoded();
        }
        m->setUrls(urls);
        m->setData(QStringLiteral("x-special/gnome-copied-files"), gnome);
        QGuiApplication::clipboard()->setMimeData(m);
    }
signals:
    void changed();
};
