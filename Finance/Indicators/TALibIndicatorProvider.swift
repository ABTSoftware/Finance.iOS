//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// TALibIndicatorProvider.swift is part of SCICHART®, High Performance Scientific Charts
// For full terms and conditions of the license, see http://www.scichart.com/scichart-eula/
//
// This source code is protected by international copyright law. Unauthorized
// reproduction, reverse-engineering, or distribution of all or any portion of
// this source code is strictly prohibited.
//
// This source code contains confidential and proprietary trade secrets of
// SciChart Ltd., and should at no time be copied, transferred, sold,
// distributed or made available without express written permission.
//******************************************************************************

import SciChart
import SwiftCCTALib

public protocol IEnumName {
    var name: String { get }
}

public enum TA_MAType_Option: Int, CaseIterable, IEnumName {
    case sma = 0
    case ema = 1
    case wma = 2
    case dema = 3
    case tema = 4
    case trima = 5
    case kama = 6
    case mama = 7
    case t3 = 8
    
    public var maType: TA_MAType {
        return TA_MAType(UInt32(self.rawValue))
    }
    
    public var name: String {
        switch self {
        case .sma: return "SMA"
        case .ema: return "EMA"
        case .wma: return "WMA"
        case .dema: return "DEMA"
        case .tema: return "TEMA"
        case .trima: return "TRIMA"
        case .kama: return "KAMA"
        case .mama: return "MAMA"
        case .t3: return "T3"
        }
    }
}

extension SCIDoubleValues {
    func normalize(outStartIndex: TA_Integer, outCount: TA_Integer) {
        if (outCount > 0) {
            self.withUnsafeMutablePointer { pointer in
                pointer.advanced(by: Int(outStartIndex)).assign(from: pointer, count: Int(outCount))
                pointer.assign(repeating: Double.nan, count: Int(outStartIndex))
            }
        }
    }
    
    func fillWithNaNs(count: Int) {
        self.withUnsafeMutablePointer { pointer in
            pointer.assign(repeating: Double.nan, count: count)
        }
    }
}

public class TALibIndicatorProvider: NSObject {
    
    public class SingleInputTaLibIndicator: IndicatorBase {
        
        @EditableProperty
        public var input: DataSourceEditableProperty!
        
        public init(name: String, inputId: DataSourceId) {
            super.init(name: name)
            
            self.input = DataSourceEditableProperty(
                name: FinanceString.indicatorSingleInput.name,
                parentName: name,
                initialValue: inputId,
                listener: { [weak self] id, value in
                    self?.dependsOn(propertyId: FinanceString.indicatorSingleInput, value: value)
                    self?.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func onDataDrasticallyChanged(dataManager: IDataManager) {
            if !isAttached { return }
            
            if let inputValues = dataManager.getYValues(id: input.value) {
                
                let count = inputValues.count
                if count == 0 { return }
                
                let endIndex = count - 1
                
                // TODO end index should be inclusive
                compute(0, endIndex, inputValues)
            } else { clear() }
        }
        
        func compute(_ startIndex: Int, _ endIndex: Int, _ inputValues: SCIDoubleValues) {
            fatalError("Must be implemented in subclasses")
        }
        
        func clear() {
            fatalError("Must be implemented in subclasses")
        }
    }
    
    public class SingleInputOutputTaLibIndicator: SingleInputTaLibIndicator {
        public let outputId: DataSourceId
        public let outputValues: SCIDoubleValues
        public let outputChangedArgs: DataSourceChangedArgs
                
        public init(name: String, inputId: DataSourceId, outputId: DataSourceId) {
            self.outputId = outputId
            self.outputValues = SCIDoubleValues()
            self.outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([outputId]))
            
            super.init(name: name, inputId: inputId)
        }
        
        override func clear() {
            outputValues.clear()
        }
        
        override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: outputId, values: outputValues)
        }
        
        override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: outputId)
        }
        
        public override func compute(_ startIndex: Int, _ endIndex: Int, _ inputValues: SCIDoubleValues) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputValues.count
            
            outputValues.count = count
            if tryCompute(TA_Integer(startIndex), TA_Integer(endIndex), inputValues, &outStartIndex, &outCount, outputValues) {
                outputValues.normalize(outStartIndex: outStartIndex, outCount: outCount)
            } else {
                outputValues.fillWithNaNs(count: count)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            fatalError("Must be implemented in subclasses")
        }
    }
    
    public class SmaIndicator: SingleInputOutputTaLibIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        public init(period: Int, inputId: DataSourceId, outputId: DataSourceId) {
            super.init(name: FinanceString.smaIndicatorName.name, inputId: inputId, outputId: outputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorSmaPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_SMA_Lookback(TA_Integer(period.value)),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inputValues.withUnsafePointer { inputValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_SMA(
                    startIndex,
                    endIndex,
                    inputValuesPointer,
                    TA_Integer(period.value),
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}
            
            return true
        }
        
        public override func reset() {
            period.reset()
        }
    }
    
    public class MacdIndicator: SingleInputTaLibIndicator {
        
        @EditableProperty
        public var slow: PeriodEditableProperty!
        
        @EditableProperty
        public var fast: PeriodEditableProperty!
        
        @EditableProperty
        public var signal: PeriodEditableProperty!
        
        public let macdId: DataSourceId
        public let macdSignalId: DataSourceId
        public let macdHistId: DataSourceId
        
        public let outputChangedArgs: DataSourceChangedArgs
        
        private var macd = SCIDoubleValues()
        private var macdSignal = SCIDoubleValues()
        private var macdHist = SCIDoubleValues()
        
        public init(
            inputId: DataSourceId,
            macdId: DataSourceId,
            macdSignalId: DataSourceId,
            macdHistId: DataSourceId,
            slow: Int,
            fast: Int,
            signal: Int
        ) {
            self.macdId = macdId
            self.macdSignalId = macdSignalId
            self.macdHistId = macdHistId
            
            outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([macdId, macdSignalId, macdHistId]))
            
            super.init(name: FinanceString.macdIndicatorName.name, inputId: inputId)
            
            self.slow = PeriodEditableProperty(
                name: FinanceString.indicatorMacdSlow.name,
                parentName: name,
                initialValue: slow,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.fast = PeriodEditableProperty(
                name: FinanceString.indicatorMacdFast.name,
                parentName: name,
                initialValue: fast,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.signal = PeriodEditableProperty(
                name: FinanceString.indicatorMacdSignal.name,
                parentName: name,
                initialValue: signal,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func clear() {
            macd.clear()
            macdSignal.clear()
            macdHist.clear()
        }
        
        public override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: macdId, values: macd)
            dataManager.registerYValuesSource(id: macdSignalId, values: macdSignal)
            dataManager.registerYValuesSource(id: macdHistId, values: macdHist)
        }
        
        public override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: macdId)
            dataManager.unregisterYValuesSource(id: macdSignalId)
            dataManager.unregisterYValuesSource(id: macdHistId)
        }
        
        public override func compute(_ startIndex: Int, _ endIndex: Int, _ inputValues: SCIDoubleValues) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputValues.count
            
            macd.count = count
            macdSignal.count = count
            macdHist.count = count
            
            if shouldSkipCalculation(
                lookback: TA_MACD_Lookback(TA_Integer(fast.value), TA_Integer(slow.value), TA_Integer(signal.value)),
                startIndex: TA_Integer(startIndex),
                endIndex: TA_Integer(endIndex)
            ) {
                macd.fillWithNaNs(count: count)
                macdSignal.fillWithNaNs(count: count)
                macdHist.fillWithNaNs(count: count)
            } else {
                inputValues.withUnsafePointer { inputValuesPointer -> Void in
                macd.withUnsafeMutablePointer { macdPointer -> Void in
                macdSignal.withUnsafeMutablePointer { macdSignalPointer -> Void in
                macdHist.withUnsafeMutablePointer { macdHistPointer -> Void in
                    TA_MACD(
                        TA_Integer(startIndex),
                        TA_Integer(endIndex),
                        inputValuesPointer,
                        TA_Integer(fast.value),
                        TA_Integer(slow.value),
                        TA_Integer(signal.value),
                        &outStartIndex,
                        &outCount,
                        macdPointer,
                        macdSignalPointer,
                        macdHistPointer
                    )
                }}}}
                
                macd.normalize(outStartIndex: outStartIndex, outCount: outCount)
                macdSignal.normalize(outStartIndex: outStartIndex, outCount: outCount)
                macdHist.normalize(outStartIndex: outStartIndex, outCount: outCount)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        public override func reset() {
            slow.reset()
            fast.reset()
            signal.reset()
        }
    }
    
    public class RSIIndicator: SingleInputOutputTaLibIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        public init(period: Int, inputId: DataSourceId, outputId: DataSourceId) {
            super.init(name: FinanceString.rsiIndicatorName.name, inputId: inputId, outputId: outputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorRsiPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_RSI_Lookback(TA_Integer(period.value)),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inputValues.withUnsafePointer { inputValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_RSI(
                    startIndex,
                    endIndex,
                    inputValuesPointer,
                    TA_Integer(period.value),
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}
            
            return true
        }
        
        public override func reset() {
            period.reset()
        }
    }
    
    public class BBandsIndicator: SingleInputTaLibIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        @EditableProperty
        public var devUp: DoubleEditableProperty!
        
        @EditableProperty
        public var devDown: DoubleEditableProperty!
        
        @EditableProperty
        public var maType: TA_MAType_EditableProperty!
        
        private var lowerBand = SCIDoubleValues()
        private var middleBand = SCIDoubleValues()
        private var upperBand = SCIDoubleValues()
        
        public let lowerBandId: DataSourceId
        public let middleBandId: DataSourceId
        public let upperBandId: DataSourceId
        
        public let outputChangedArgs: DataSourceChangedArgs
        
        public init(
            period: Int,
            devUp: Double,
            devDown: Double,
            maType: TA_MAType_Option,
            inputId: DataSourceId,
            lowerBandId: DataSourceId,
            middleBandId: DataSourceId,
            upperBandId: DataSourceId
        ) {
            self.lowerBandId = lowerBandId
            self.middleBandId = middleBandId
            self.upperBandId = upperBandId
            
            outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([lowerBandId, middleBandId, upperBandId]))
            
            super.init(name: FinanceString.bBandsIndicatorName.name, inputId: inputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorBBandsPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.devUp = DoubleEditableProperty(
                name: FinanceString.indicatorBBandsDevUp.name,
                parentName: name,
                initialValue: devUp,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.devDown = DoubleEditableProperty(
                name: FinanceString.indicatorBBandsDevDown.name,
                parentName: name,
                initialValue: devDown,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.maType = TA_MAType_EditableProperty(
                name: FinanceString.indicatorBBandsMAType.name,
                parentName: name,
                initialValue: maType,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func clear() {
            lowerBand.clear()
            middleBand.clear()
            upperBand.clear()
        }
        
        public override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: lowerBandId, values: lowerBand)
            dataManager.registerYValuesSource(id: middleBandId, values: middleBand)
            dataManager.registerYValuesSource(id: upperBandId, values: upperBand)
        }
        
        public override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: lowerBandId)
            dataManager.unregisterYValuesSource(id: middleBandId)
            dataManager.unregisterYValuesSource(id: upperBandId)
        }
        
        public override func compute(_ startIndex: Int, _ endIndex: Int, _ inputValues: SCIDoubleValues) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputValues.count
            
            lowerBand.count = count
            middleBand.count = count
            upperBand.count = count
            
            if shouldSkipCalculation(
                lookback: TA_BBANDS_Lookback(
                    TA_Integer(period.value),
                    devUp.value,
                    devDown.value,
                    maType.enumValue.maType
                ),
                startIndex: TA_Integer(startIndex),
                endIndex: TA_Integer(endIndex)
            ) {
                lowerBand.fillWithNaNs(count: count)
                middleBand.fillWithNaNs(count: count)
                upperBand.fillWithNaNs(count: count)
            } else {
                inputValues.withUnsafePointer { inputValuesPointer -> Void in
                lowerBand.withUnsafeMutablePointer { lowerBandPointer -> Void in
                middleBand.withUnsafeMutablePointer { middleBandPointer -> Void in
                upperBand.withUnsafeMutablePointer { upperBandPointer -> Void in
                    TA_BBANDS(
                        TA_Integer(startIndex),
                        TA_Integer(endIndex),
                        inputValuesPointer,
                        TA_Integer(period.value),
                        devUp.value,
                        devDown.value,
                        maType.enumValue.maType,
                        &outStartIndex,
                        &outCount,
                        lowerBandPointer,
                        middleBandPointer,
                        upperBandPointer
                    )
                }}}}
                
                lowerBand.normalize(outStartIndex: outStartIndex, outCount: outCount)
                middleBand.normalize(outStartIndex: outStartIndex, outCount: outCount)
                upperBand.normalize(outStartIndex: outStartIndex, outCount: outCount)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        public override func reset() {
            period.reset()
            devUp.reset()
            devDown.reset()
            maType.reset()
        }
    }
    
    public class HT_TrendlineIndicator: SingleInputOutputTaLibIndicator {

        public init(inputId: DataSourceId, outputId: DataSourceId) {
            super.init(name: FinanceString.htTrendlineIndicatorName.name, inputId: inputId, outputId: outputId)
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_HT_TRENDLINE_Lookback(),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inputValues.withUnsafePointer { inputValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_HT_TRENDLINE(
                    startIndex,
                    endIndex,
                    inputValuesPointer,
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}
            
            return true
        }
        
        public override func reset() {}
    }
    
    public class STDDevIndicator: SingleInputOutputTaLibIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        @EditableProperty
        public var dev: DoubleEditableProperty!
        
        public init(period: Int, dev: Double, inputId: DataSourceId, outputId: DataSourceId) {
            super.init(name: FinanceString.stdDevIndicatorName.name, inputId: inputId, outputId: outputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorStdDevPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.dev = DoubleEditableProperty(
                name: FinanceString.indicatorStdDev_Dev.name,
                parentName: name,
                initialValue: dev,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_STDDEV_Lookback(TA_Integer(period.value), dev.value),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inputValues.withUnsafePointer { inputValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_STDDEV(
                    startIndex,
                    endIndex,
                    inputValuesPointer,
                    TA_Integer(period.value),
                    dev.value,
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}
            
            return true
        }
        
        public override func reset() {
            period.reset()
            dev.reset()
        }
    }
    
    public class EMAIndicator: SingleInputOutputTaLibIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!

        public init(period: Int, inputId: DataSourceId, outputId: DataSourceId) {
            super.init(name: FinanceString.emaIndicatorName.name, inputId: inputId, outputId: outputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorEmaPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_EMA_Lookback(TA_Integer(period.value)),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inputValues.withUnsafePointer { inputValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_EMA(
                    startIndex,
                    endIndex,
                    inputValuesPointer,
                    TA_Integer(period.value),
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}
            
            return true
        }
        
        public override func reset() {
            period.reset()
        }
    }
    
    public class HighLowCloseInputIndicator: IndicatorBase {
        
        @EditableProperty
        public var inputHigh: DataSourceEditableProperty!
        
        @EditableProperty
        public var inputLow: DataSourceEditableProperty!
        
        @EditableProperty
        public var inputClose: DataSourceEditableProperty!
        
        public init(
            name: String,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            inputCloseId: DataSourceId
        ) {
            super.init(name: name)
            
            inputHigh = DataSourceEditableProperty(
                name: FinanceString.indicatorHighInput.name,
                parentName: name,
                initialValue: inputHighId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorHighInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            inputLow = DataSourceEditableProperty(
                name: FinanceString.indicatorLowInput.name,
                parentName: name,
                initialValue: inputLowId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorLowInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            inputClose = DataSourceEditableProperty(
                name: FinanceString.indicatorCloseInput.name,
                parentName: name,
                initialValue: inputCloseId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorCloseInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func onDataDrasticallyChanged(dataManager: IDataManager) {
            guard isAttached,
                  let inputHighValues = dataManager.getYValues(id: inputHigh.value),
                  let inputLowValues = dataManager.getYValues(id: inputLow.value),
                  let inputCloseValues = dataManager.getYValues(id: inputClose.value)
            else {
                clear()
                return
            }
            
            let count = inputCloseValues.count
            if count == 0 { return }
            
            let endIndex = count - 1
            
            // TODO end index should be inclusive
            compute(
                startIndex: 0,
                endIndex: endIndex,
                inputHighValues: inputHighValues,
                inputLowValues: inputLowValues,
                inputCloseValues: inputCloseValues
            )
        }
        
        public func clear() {
            fatalError("Must be implemented in subclasses")
        }
        
        public func compute(
            startIndex: Int,
            endIndex: Int,
            inputHighValues: SCIDoubleValues,
            inputLowValues: SCIDoubleValues,
            inputCloseValues: SCIDoubleValues
        ) {
            fatalError("Must be implemented in subclasses")
        }
        
        public override func reset() {
            inputHigh.reset()
            inputLow.reset()
            inputClose.reset()
        }
    }
    
    public class HighLowCloseInputSingleOutputIndicator: HighLowCloseInputIndicator {
        public let outputId: DataSourceId
        public var outputValues: SCIDoubleValues
        public let outputChangedArgs: DataSourceChangedArgs
        
        public init(
            name: String,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            inputCloseId: DataSourceId,
            outputId: DataSourceId
        ) {
            self.outputId = outputId
            self.outputValues = SCIDoubleValues()
            self.outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([outputId]))
            
            super.init(
                name: name,
                inputHighId: inputHighId,
                inputLowId: inputLowId,
                inputCloseId: inputCloseId
            )
        }
        
        public override func clear() {
            outputValues.clear()
        }
        
        public override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: outputId, values: outputValues)
        }
        
        override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: outputId)
        }
        
        public override func compute(
            startIndex: Int,
            endIndex: Int,
            inputHighValues: SCIDoubleValues,
            inputLowValues: SCIDoubleValues,
            inputCloseValues: SCIDoubleValues
        ) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputCloseValues.count
            outputValues.count = count
            
            if tryCompute(
                TA_Integer(startIndex),
                TA_Integer(endIndex),
                inputHighValues,
                inputLowValues,
                inputCloseValues,
                &outStartIndex,
                &outCount,
                outputValues
            ) {
                outputValues.normalize(outStartIndex: outStartIndex, outCount: outCount)
            } else {
                outputValues.fillWithNaNs(count: count)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inHighValues: SCIDoubleValues,
            _ inLowValues: SCIDoubleValues,
            _ inCloseValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            fatalError("Must be implemented in subclasses")
        }
    }
    
    public class ADXIndicator: HighLowCloseInputSingleOutputIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        public init(
            period: Int,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            inputCloseId: DataSourceId,
            outputId: DataSourceId
        ) {
            super.init(
                name: FinanceString.adxIndicatorName.name,
                inputHighId: inputHighId,
                inputLowId: inputLowId,
                inputCloseId: inputCloseId,
                outputId: outputId
            )
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorAdxPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inHighValues: SCIDoubleValues,
            _ inLowValues: SCIDoubleValues,
            _ inCloseValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_ADX_Lookback(TA_Integer(period.value)),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }

            inHighValues.withUnsafePointer { inHighValuesPointer -> Void in
            inLowValues.withUnsafePointer { inLowValuesPointer -> Void in
            inCloseValues.withUnsafePointer { inCloseValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_ADX(
                    startIndex,
                    endIndex,
                    inHighValuesPointer,
                    inLowValuesPointer,
                    inCloseValuesPointer,
                    TA_Integer(period.value),
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}}}
            
            return true
        }
        
        public override func reset() {
            super.reset()
            
            period.reset()
        }
    }
    
    public class ATRIndicator: HighLowCloseInputSingleOutputIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        public init(
            period: Int,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            inputCloseId: DataSourceId,
            outputId: DataSourceId
        ) {
            super.init(
                name: FinanceString.atrIndicatorName.name,
                inputHighId: inputHighId,
                inputLowId: inputLowId,
                inputCloseId: inputCloseId,
                outputId: outputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorAtrPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inHighValues: SCIDoubleValues,
            _ inLowValues: SCIDoubleValues,
            _ inCloseValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_ATR_Lookback(TA_Integer(period.value)),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inHighValues.withUnsafePointer { inHighValuesPointer -> Void in
            inLowValues.withUnsafePointer { inLowValuesPointer -> Void in
            inCloseValues.withUnsafePointer { inCloseValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_ATR(
                    startIndex,
                    endIndex,
                    inHighValuesPointer,
                    inLowValuesPointer,
                    inCloseValuesPointer,
                    TA_Integer(period.value),
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}}}
            
            return true
        }
        
        public override func reset() {
            super.reset()
            
            period.reset()
        }
    }
    
    public class CCIIndicator: HighLowCloseInputSingleOutputIndicator {
        
        @EditableProperty
        public var period: PeriodEditableProperty!
        
        public init(
            period: Int,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            inputCloseId: DataSourceId,
            outputId: DataSourceId
        ) {
            super.init(
                name: FinanceString.cciIndicatorName.name,
                inputHighId: inputHighId,
                inputLowId: inputLowId,
                inputCloseId: inputCloseId,
                outputId: outputId)
            
            self.period = PeriodEditableProperty(
                name: FinanceString.indicatorCciPeriod.name,
                parentName: name,
                initialValue: period,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inHighValues: SCIDoubleValues,
            _ inLowValues: SCIDoubleValues,
            _ inCloseValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_CCI_Lookback(TA_Integer(period.value)),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inHighValues.withUnsafePointer { inHighValuesPointer -> Void in
            inLowValues.withUnsafePointer { inLowValuesPointer -> Void in
            inCloseValues.withUnsafePointer { inCloseValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_CCI(
                    startIndex,
                    endIndex,
                    inHighValuesPointer,
                    inLowValuesPointer,
                    inCloseValuesPointer,
                    TA_Integer(period.value),
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}}}
            
            return true
        }
        
        public override func reset() {
            super.reset()
            
            period.reset()
        }
    }
    
    public class CloseVolumeInputIndicator: IndicatorBase {
        
        @EditableProperty
        public var inputClose: DataSourceEditableProperty!
        
        @EditableProperty
        public var inputVolume: DataSourceEditableProperty!
        
        public init(
            name: String,
            inputCloseId: DataSourceId,
            inputVolumeId: DataSourceId
        ) {
            super.init(name: name)
            
            inputClose = DataSourceEditableProperty(
                name: FinanceString.indicatorCloseInput.name,
                parentName: name,
                initialValue: inputCloseId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorCloseInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            inputVolume = DataSourceEditableProperty(
                name: FinanceString.indicatorVolumeInput.name,
                parentName: name,
                initialValue: inputVolumeId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorVolumeInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func onDataDrasticallyChanged(dataManager: IDataManager) {
            guard isAttached,
                  let inputCloseValues = dataManager.getYValues(id: inputClose.value),
                  let inputVolumeValues = dataManager.getYValues(id: inputVolume.value)
            else {
                clear()
                return
            }
            
            let count = inputCloseValues.count
            if count == 0 { return }
            
            let endIndex = count - 1
            
            // TODO end index should be inclusive
            compute(
                startIndex: 0,
                endIndex: endIndex,
                inputCloseValues: inputCloseValues,
                inputVolumeValues: inputVolumeValues
            )
        }
        
        public func clear() {
            fatalError("Must be implemented in subclasses")
        }
        
        public func compute(
            startIndex: Int,
            endIndex: Int,
            inputCloseValues: SCIDoubleValues,
            inputVolumeValues: SCIDoubleValues
        ) {
            fatalError("Must be implemented in subclasses")
        }
        
        public override func reset() {
            inputClose.reset()
            inputVolume.reset()
        }
    }
    
    public class CloseVolumeInputSingleOutputIndicator: CloseVolumeInputIndicator {
        public let outputId: DataSourceId
        public let outputValues: SCIDoubleValues
        public let outputChangedArgs: DataSourceChangedArgs
        
        init(
            name: String,
            inputCloseId: DataSourceId,
            inputVolumeId: DataSourceId,
            outputId: DataSourceId
        ) {
            self.outputId = outputId
            self.outputValues = SCIDoubleValues()
            self.outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([outputId]))
            
            super.init(name: name, inputCloseId: inputCloseId, inputVolumeId: inputVolumeId)
        }
        
        public override func clear() {
            outputValues.clear()
        }
        
        override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: outputId, values: outputValues)
        }
        
        override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: outputId)
        }
        
        public override func compute(startIndex: Int, endIndex: Int, inputCloseValues: SCIDoubleValues, inputVolumeValues: SCIDoubleValues) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputCloseValues.count
            
            outputValues.count = count
            if tryCompute(
                TA_Integer(startIndex),
                TA_Integer(endIndex),
                inputCloseValues,
                inputVolumeValues,
                &outStartIndex,
                &outCount,
                outputValues
            ) {
                outputValues.normalize(outStartIndex: outStartIndex, outCount: outCount)
            } else {
                outputValues.fillWithNaNs(count: count)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputCloseValues: SCIDoubleValues,
            _ inputVolumeValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            fatalError("Must be implemented in subclasses")
        }
    }
    
    public class OBVIndicator: CloseVolumeInputSingleOutputIndicator {

        public init(
            inputCloseId: DataSourceId,
            inputVolumeId: DataSourceId,
            outputId: DataSourceId
        ) {
            super.init(
                name: FinanceString.obvIndicatorName.name,
                inputCloseId: inputCloseId,
                inputVolumeId: inputVolumeId,
                outputId: outputId)
        }
        
        public override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: outputId, values: outputValues)
        }
        
        override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: outputId)
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputCloseValues: SCIDoubleValues,
            _ inputVolumeValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_OBV_Lookback(),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
            
            inputCloseValues.withUnsafePointer { inCloseValuesPointer -> Void in
            inputVolumeValues.withUnsafePointer { inVolumeValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_OBV(
                    TA_Integer(startIndex),
                    TA_Integer(endIndex),
                    inCloseValuesPointer,
                    inVolumeValuesPointer,
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}}
            
            return true
        }
    }
    
    public class HighLowInputIndicator: IndicatorBase {
        
        @EditableProperty
        public var inputHigh: DataSourceEditableProperty!
        
        @EditableProperty
        public var inputLow: DataSourceEditableProperty!
        
        public init(name: String, inputHighId: DataSourceId, inputLowId: DataSourceId) {
            super.init(name: name)
            
            inputHigh = DataSourceEditableProperty(
                name: FinanceString.indicatorHighInput.name,
                parentName: name,
                initialValue: inputHighId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorHighInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            inputLow = DataSourceEditableProperty(
                name: FinanceString.indicatorLowInput.name,
                parentName: name,
                initialValue: inputLowId,
                listener: { [weak self] id, value in
                    guard let self = self else { return }
                    
                    self.dependsOn(propertyId: FinanceString.indicatorLowInput, value: value)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        override func onDataDrasticallyChanged(dataManager: IDataManager) {
            guard isAttached,
                  let inputHighValues = dataManager.getYValues(id: inputHigh.value),
                  let inputLowValues = dataManager.getYValues(id: inputLow.value)
            else {
                clear()
                return
            }
            
            let count = inputHighValues.count
            if count == 0 { return }
            
            let endIndex = count - 1
            
            // TODO end index should be inclusive
            compute(
                startIndex: 0,
                endIndex: endIndex,
                inputHighValues: inputHighValues,
                inputLowValues: inputLowValues
            )
        }
        
        public func compute(
            startIndex: Int,
            endIndex: Int,
            inputHighValues: SCIDoubleValues,
            inputLowValues: SCIDoubleValues
        ) {
            fatalError("Must be implemented in subclasses")
        }
        
        public func clear() {
            fatalError("Must be implemented in subclasses")
        }
        
        public override func reset() {
            inputHigh.reset()
            inputLow.reset()
        }
    }
    
    public class HighLowInputSingleOutputIndicator: HighLowInputIndicator {
        public let outputId: DataSourceId
        public let outputValues: SCIDoubleValues
        public let outputChangedArgs: DataSourceChangedArgs
        
        init(
            name: String,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            outputId: DataSourceId
        ) {
            self.outputId = outputId
            self.outputValues = SCIDoubleValues()
            self.outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([outputId]))
            
            super.init(name: name, inputHighId: inputHighId, inputLowId: inputLowId)
        }
        
        public override func clear() {
            outputValues.clear()
        }
        
        override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: outputId, values: outputValues)
        }
        
        override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: outputId)
        }
        
        public override func compute(
            startIndex: Int,
            endIndex: Int,
            inputHighValues: SCIDoubleValues,
            inputLowValues: SCIDoubleValues
        ) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputHighValues.count
            outputValues.count = count
            
            if tryCompute(
                TA_Integer(startIndex),
                TA_Integer(endIndex),
                inputHighValues,
                inputLowValues,
                &outStartIndex,
                &outCount,
                outputValues
            ) {
                outputValues.normalize(outStartIndex: outStartIndex, outCount: outCount)
            } else {
                outputValues.fillWithNaNs(count: count)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputHighValues: SCIDoubleValues,
            _ inputLowValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            fatalError("Must be implemented in subclasses")
        }
    }
    
    public class SARIndicator: HighLowInputSingleOutputIndicator {
        @EditableProperty
        public var acceleration: PositiveDoubleEditableProperty!
        
        @EditableProperty
        public var maximum: PositiveDoubleEditableProperty!
        
        public init(
            acceleration: Double,
            maximum: Double,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            outputId: DataSourceId
        ) {
            super.init(
                name: FinanceString.sarIndicatorName.name,
                inputHighId: inputHighId,
                inputLowId: inputLowId,
                outputId: outputId
            )
            
            self.acceleration = PositiveDoubleEditableProperty(
                name: FinanceString.indicatorSarAcceleration.name,
                parentName: name,
                initialValue: acceleration,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.maximum = PositiveDoubleEditableProperty(
                name: FinanceString.indicatorSarMaximum.name,
                parentName: name,
                initialValue: maximum,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        public override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: outputId, values: outputValues)
        }
        
        override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: outputId)
        }
        
        override func tryCompute(
            _ startIndex: TA_Integer,
            _ endIndex: TA_Integer,
            _ inputHighValues: SCIDoubleValues,
            _ inputLowValues: SCIDoubleValues,
            _ outStartIndex: inout TA_Integer,
            _ outCount: inout TA_Integer,
            _ outputValues: SCIDoubleValues
        ) -> Bool {
            if shouldSkipCalculation(
                lookback: TA_SAR_Lookback(acceleration.value, maximum.value),
                startIndex: startIndex,
                endIndex: endIndex
            ) {
                return false
            }
                
            inputHighValues.withUnsafePointer { inHighValuesPointer -> Void in
            inputLowValues.withUnsafePointer { inLowValuesPointer -> Void in
            outputValues.withUnsafeMutablePointer { outputValuesPointer -> Void in
                TA_SAR(
                    TA_Integer(startIndex),
                    TA_Integer(endIndex),
                    inHighValuesPointer,
                    inLowValuesPointer,
                    acceleration.value,
                    maximum.value,
                    &outStartIndex,
                    &outCount,
                    outputValuesPointer
                )
            }}}
            
            return true
        }
        
        public override func reset() {
            super.reset()
            
            acceleration.reset()
            maximum.reset()
        }
    }

    public class StochIndicator: HighLowCloseInputIndicator {
        
        @EditableProperty
        public var fastK: FastSlowPeriodEditableProperty!
        
        @EditableProperty
        public var slowK: FastSlowPeriodEditableProperty!
        
        @EditableProperty
        public var slowD: FastSlowPeriodEditableProperty!
        
        @EditableProperty
        public var slowK_maType: TA_MAType_EditableProperty!
        
        @EditableProperty
        public var slowD_maType: TA_MAType_EditableProperty!
        
        private var slowKValues = SCIDoubleValues()
        private var slowDValues = SCIDoubleValues()
        
        public let slowKId: DataSourceId
        public let slowDId: DataSourceId
        
        public let outputChangedArgs: DataSourceChangedArgs
        
        public init(
            fastK: Int,
            slowK: Int,
            slowD: Int,
            slowK_maType: TA_MAType_Option,
            slowD_maType: TA_MAType_Option,
            inputHighId: DataSourceId,
            inputLowId: DataSourceId,
            inputCloseId: DataSourceId,
            slowKId: DataSourceId,
            slowDId: DataSourceId
        ) {
            self.slowKId = slowKId
            self.slowDId = slowDId
            
            outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([slowKId, slowDId]))
            
            super.init(
                name: FinanceString.stochIndicatorName.name,
                inputHighId: inputHighId,
                inputLowId: inputLowId,
                inputCloseId: inputCloseId
            )
            
            self.fastK = FastSlowPeriodEditableProperty(
                name: FinanceString.indicatorStochFastK.name,
                parentName: name,
                initialValue: fastK,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.slowK = FastSlowPeriodEditableProperty(
                name: FinanceString.indicatorStochSlowK.name,
                parentName: name,
                initialValue: slowK,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.slowD = FastSlowPeriodEditableProperty(
                name: FinanceString.indicatorStochSlowD.name,
                parentName: name,
                initialValue: slowD,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.slowK_maType = TA_MAType_EditableProperty(
                name: FinanceString.indicatorStochSlowK_MAType.name,
                parentName: name,
                initialValue: slowK_maType,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
            
            self.slowD_maType = TA_MAType_EditableProperty(
                name: FinanceString.indicatorStochSlowD_MAType.name,
                parentName: name,
                initialValue: slowD_maType,
                listener: { [weak self] id, _ in
                    guard let self = self else { return }
                    
                    self.onDataSourceChanged(args: self.outputChangedArgs)
                    self.onPropertyChanged(propertyId: id)
                }
            )
        }
        
        public override func clear() {
            slowKValues.clear()
            slowDValues.clear()
        }
        
        public override func onDataManagerAttached(_ dataManager: IDataManager) {
            super.onDataManagerAttached(dataManager)
            
            dataManager.registerYValuesSource(id: slowKId, values: slowKValues)
            dataManager.registerYValuesSource(id: slowDId, values: slowDValues)
        }
        
        public override func onDataManagerDetached(_ dataManager: IDataManager) {
            super.onDataManagerDetached(dataManager)
            
            dataManager.unregisterYValuesSource(id: slowKId)
            dataManager.unregisterYValuesSource(id: slowDId)
        }
        
        public override func compute(
            startIndex: Int,
            endIndex: Int,
            inputHighValues: SCIDoubleValues,
            inputLowValues: SCIDoubleValues,
            inputCloseValues: SCIDoubleValues
        ) {
            var outStartIndex: TA_Integer = 0
            var outCount: TA_Integer = 0
            let count = inputCloseValues.count
            
            slowKValues.count = count
            slowDValues.count = count
            
            if shouldSkipCalculation(
                lookback: TA_STOCH_Lookback(
                    TA_Integer(fastK.value),
                    TA_Integer(slowK.value),
                    slowK_maType.enumValue.maType,
                    TA_Integer(slowD.value),
                    slowD_maType.enumValue.maType),
                startIndex: TA_Integer(startIndex),
                endIndex: TA_Integer(endIndex)
            ) {
                slowKValues.fillWithNaNs(count: count)
                slowDValues.fillWithNaNs(count: count)
            } else {
                inputHighValues.withUnsafePointer { inHighValuesPointer -> Void in
                inputLowValues.withUnsafePointer { inLowValuesPointer -> Void in
                inputCloseValues.withUnsafePointer { inCloseValuesPointer -> Void in
                slowKValues.withUnsafeMutablePointer { slowKPointer -> Void in
                slowDValues.withUnsafeMutablePointer { slowDPointer -> Void in
                    TA_STOCH(
                        TA_Integer(startIndex),
                        TA_Integer(endIndex),
                        inHighValuesPointer,
                        inLowValuesPointer,
                        inCloseValuesPointer,
                        TA_Integer(fastK.value),
                        TA_Integer(slowK.value),
                        slowK_maType.enumValue.maType,
                        TA_Integer(slowD.value),
                        slowD_maType.enumValue.maType,
                        &outStartIndex,
                        &outCount,
                        slowKPointer,
                        slowDPointer
                    )
                }}}}}
                
                slowKValues.normalize(outStartIndex: outStartIndex, outCount: outCount)
                slowDValues.normalize(outStartIndex: outStartIndex, outCount: outCount)
            }
            
            onDataProviderChanged(args: outputChangedArgs)
        }
        
        public override func reset() {
            super.reset()
            
            fastK.reset()
            slowK.reset()
            slowD.reset()
            slowK_maType.reset()
            slowD_maType.reset()
        }
    }
}
