#pragma once

#include <QQuickImageProvider>

class PuzzleController : public QObject, public QQuickImageProvider
{
    Q_OBJECT
    Q_PROPERTY(QString puzzleFilename MEMBER m_puzzleFilename WRITE setPuzzleFilename NOTIFY puzzleFilenameChanged)
    Q_PROPERTY(int pieceCount MEMBER m_pieceCount NOTIFY pieceCountChanged)
    Q_PROPERTY(int rowCount MEMBER m_rowCount NOTIFY rowCountChanged)
    Q_PROPERTY(int columnCount MEMBER m_columnCount NOTIFY columnCountChanged)

public:
    explicit PuzzleController(QObject* parent = nullptr);

    QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);

public slots:
    void setPuzzleFilename(QString puzzleFilename);
    void setPieceCount(int pieceCount);

signals:
    void puzzleFilenameChanged(QString puzzleFilename);
    void pieceCountChanged(int pieceCount);
    void rowCountChanged(int rowCount);
    void columnCountChanged(int columnCount);

private:
    QImage m_puzzle;

    int m_pieceCount = 0;
    int m_rowCount = 0;
    int m_columnCount = 0;
    QString m_puzzleFilename;
};
