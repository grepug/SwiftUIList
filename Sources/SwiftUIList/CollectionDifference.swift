/*
 This extension generates an array of steps that can be applied sequentially to an interface, or
 associated collection, to remove, insert AND move items. Apart from the first and last steps, all
 step indexes are transient and do not relate directly to the start or end collections.
 
 This is complicated than it first appears and not something that I could reduced further. The
 standard Changes are ordered: removals high->low, insertions low->high. Generating moves based on
 insertions means that the associated removes are pulled out-of-order, which requires all the
 later indexes to be offset in subtly different ways.
 
 Delayed removals modify the insert indexes. Out of order removals, and insertions made before the
 delayed removals modify the removal indexes. The effect of something that hasn't happeded yet, is
 different to something that has happened but in the wrong order.
 */

extension CollectionDifference where ChangeElement: Hashable
{
    public typealias Steps = Array<CollectionDifference<ChangeElement>.ChangeStep>
    
    public enum ChangeStep {
        case insert(_ element: ChangeElement, at: Int)
        case remove(_ element: ChangeElement, at: Int)
        case move(_ element: ChangeElement, from: Int, to: Int)
    }
    
    var maxOffset: Int { Swift.max(removals.last?.offset ?? 0, insertions.last?.offset ?? 0) }
    
    public var steps: Steps {
        guard !isEmpty else { return [] }
        
        // A mapping to modify insertion indexes
        let mapSize = maxOffset + count
        var insertionMap = Array(0 ... mapSize)
        
        // Items that may have been completed early relative to the Changes
        var completeRemovals = Set<Int>()
        var completeInsertions = Set<Int>()
        
        var steps = Steps()
        
        inferringMoves().forEach { change in
            switch change {
            case let .remove(offset, element, associatedWith):
                if associatedWith != nil {
                    // Delayed removals can make step changes in insert locations
                    insertionMap.remove(at: offset)
                } else {
                    steps.append(.remove(element, at: offset))
                    completeRemovals.insert(offset)
                }

            case let.insert(offset, element, associatedWith):
                if let associatedWith = associatedWith
                {
                    let from = associatedWith
                        - completeRemovals.filter({ $0 < associatedWith}).count
                        + completeInsertions.filter({ $0 < associatedWith}).count
                    
                    // Late removals re-adjust the insertion map by reducing higher indexes
                    insertionMap.indices.forEach {
                        if insertionMap[$0] >= associatedWith { insertionMap[$0] -= 1 } }
                    
                    let to = insertionMap[offset]
                    
                    steps.append(.move(element, from: from, to: to))
                    
                    completeRemovals.insert(associatedWith)
                    completeInsertions.insert(to)
                } else {
                    let to = insertionMap[offset]
                    steps.append(.insert(element, at: to))
                    completeInsertions.insert(to)
                }
            }
        }

        return steps
    }
}

extension CollectionDifference.Change
{
    var offset: Int {
        switch self {
        case let .insert(offset, _, _): return offset
        case let .remove(offset, _, _): return offset
        }
    }
}
