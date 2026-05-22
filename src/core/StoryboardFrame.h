#ifndef STORYBOARDFRAME_H
#define STORYBOARDFRAME_H

#include <QObject>
#include <QUrl>
#include <QJsonObject>

class StoryboardFrame : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int frameNumber READ frameNumber WRITE setFrameNumber NOTIFY frameNumberChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString prompt READ prompt WRITE setPrompt NOTIFY promptChanged)
    Q_PROPERTY(QUrl imagePath READ imagePath WRITE setImagePath NOTIFY imagePathChanged)
    Q_PROPERTY(QString notes READ notes WRITE setNotes NOTIFY notesChanged)

public:
    explicit StoryboardFrame(QObject *parent = nullptr);

    int frameNumber() const;
    void setFrameNumber(int number);

    QString description() const;
    void setDescription(const QString &desc);

    QString prompt() const;
    void setPrompt(const QString &prompt);

    QUrl imagePath() const;
    void setImagePath(const QUrl &path);

    QString notes() const;
    void setNotes(const QString &notes);

    QJsonObject toJson() const;
    static StoryboardFrame* fromJson(const QJsonObject &json, QObject *parent = nullptr);

signals:
    void frameNumberChanged();
    void descriptionChanged();
    void promptChanged();
    void imagePathChanged();
    void notesChanged();

private:
    int m_frameNumber = 1;
    QString m_description;
    QString m_prompt;
    QUrl m_imagePath;
    QString m_notes;
};

#endif // STORYBOARDFRAME_H
