#include "puzzleController.h"

#include <QDir>
#include <QDebug>

PuzzleController::PuzzleController(ImageType type, Flags flags) : QQuickImageProvider(type, flags)
{
}

QImage PuzzleController::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    if (m_puzzle.isNull())
        return {};

    int index = id.split("_").at(0).toInt();

    int shortestSideLength = m_puzzle.width();

    if (m_puzzle.height() < m_puzzle.width())
        shortestSideLength = m_puzzle.height();

    int scaledWidth = shortestSideLength / m_columnCount;
    int scaledHeight = shortestSideLength / m_rowCount;

    QSize scaledSize(scaledWidth, scaledHeight);

    QImage piece(*size, QImage::Format_ARGB32);
    piece.fill(QColor("red"));

    int lastIndex = (m_rowCount * m_columnCount) - 1;

    if (index != lastIndex) {
        int row = index % m_rowCount;
        int column = index / m_columnCount;

        int x = row * scaledWidth;
        int y = column * scaledHeight;

        piece = m_puzzle.copy(x, y, scaledWidth, scaledHeight);
    }

    return piece;
}

void PuzzleController::setPieceCount(int pieceCount)
{
    m_pieceCount = pieceCount;
    m_rowCount = qRound(qSqrt(pieceCount));
    m_columnCount = qRound(qSqrt(pieceCount));

    emit pieceCountChanged(m_pieceCount);
    emit rowCountChanged(m_rowCount);
    emit columnCountChanged(m_columnCount);
}

void PuzzleController::setPuzzleFilename(QString puzzleFilename)
{
    if (m_puzzleFilename == puzzleFilename)
        return;

    m_puzzleFilename = puzzleFilename;

    m_puzzle = QImage(QDir::toNativeSeparators(QUrl(puzzleFilename).toLocalFile()));
    setPieceCount(25);

    emit puzzleFilenameChanged(m_puzzleFilename);
}
